require(data.table)
require(dplyr)
require(quanteda)
require(R6)
require(readr)


available_filters <- c("punctuation", "symbols", "numbers", "url", 
                       "profanity", "stopwords", "noletters",
                       "non-ascii")

tokenize_and_filter <- function(input, filters, language_code) {
  stopifnot(is.character(filters), 
            all(sapply(filters, function(f) f %in% available_filters)))
  if (length(input) == 1 && input == "") {
    return("")
  }
  
  tok <- as.character(tokens(input, what = "sentence")) %>% 
    tokens(remove_punct = "punctuation" %in% filters,
           remove_symbols = "symbols" %in% filters,
           remove_numbers = "numbers" %in% filters,
           remove_url = "url" %in% filters) %>%
    tokens_tolower()

  if ("stopwords" %in% filters) {
    code_map <- data.table(code = c("de_DE", "en_US", "fi_FI", "ru_RU"),
                           val = c("german", "english", "finnish", "russian"),
                           key = "code")
    tok <- tokens_remove(tok, stopwords(code_map[language_code, val]))
  }
  if ("profanity" %in% filters) {
    if (!file.exists("profanity_list.txt")) {
      profanity_url <- "https://www.cs.cmu.edu/~biglou/resources/bad-words.txt"
      download.file(profanity_url, "profanity_list.txt")
    }
    tok <- tokens_remove(tok, read_lines("profanity_list.txt"))
  }
  if ("noletters" %in% filters) {
    tok <- tokens_remove(tok, "^[^\\p{L}]+$", valuetype = "regex")
  }
  if ("non-ascii" %in% filters) {
    tok <- tokens_remove(tok, "[^[:ascii:]]", valuetype = "regex")
  }
  tok
}

generate_predictors <- function(language_code, 
                                thresh_seq = seq(2, 10), 
                                rank_seq = seq(1, 10)) {
  for(thresh in thresh_seq) {
    for (rank in rank_seq) {
      p <- predictor$new(language_code, min_threshold = thresh, max_rank = rank)
      p$save()
    }
    p <- predictor$new(language_code, min_threshold = thresh, max_rank = Inf)
    p$save()
  }
}


ngrams <- R6Class("ngrams", public = list(
  language_code = NA,
  n = NA,
  min_threshold = NA,
  max_rank = NA,
  replace = NA,
  seed = NA,
  sample_prob = NA,
  filters = NULL,
  
  initialize = function(language_code, n, min_threshold = 3, max_rank = Inf,
                        replace = FALSE, seed = 12345, sample_prob = 0.7,
                        filters = c("punctuation", "symbols", "numbers",
                                    "noletters")) {
    stopifnot(is.character(language_code), length(language_code) == 1, 
              dir.exists(file.path("final", language_code)))
    stopifnot(is.numeric(n), length(n) == 1, n >= 1)
    stopifnot(is.numeric(min_threshold), length(min_threshold) == 1)
    stopifnot(is.numeric(max_rank), length(max_rank) == 1, max_rank >= 1)
    stopifnot(is.logical(replace), length(replace) == 1)
    stopifnot(is.numeric(seed), length(seed) == 1)
    stopifnot(is.numeric(sample_prob), length(sample_prob) == 1,
              sample_prob > 0, sample_prob <= 1)
    stopifnot(is.character(filters), 
              all(sapply(filters, function(f) f %in% available_filters)))
    
    self$language_code = language_code
    self$n = as.integer(n)
    self$min_threshold = as.integer(min_threshold)
    self$max_rank = max_rank
    self$replace = replace
    self$seed = seed
    self$sample_prob = sample_prob
    self$filters = filters
  }
),

private = list(
  .corpus = NULL,
  .tokens = NULL,
  .features = NULL,
  .featurecounts = NULL,
  .gt_counts = NULL,
  .table = NULL
),

active = list(
  corpus = function(value) {
    if (missing(value)) {
      if (!is.null(private$.corpus) && !self$replace) {
        private$.corpus
      } else {
        corp_path <- file.path("final", self$language_code, "corpus.Rdata")
        if (file.exists(corp_path) && !self$replace) {
          print(sprintf("loading corpus from %s", corp_path))
          load(file = corp_path)
          private$.corpus <- corp; rm(corp); gc(FALSE)
          private$.corpus
        } else {
          print("generating train/test sets...")
          options(readr.show_progress = FALSE)
          files <- list.files(file.path("final", self$language_code))
          for (f in files) {
            if (grepl(pattern = "(?<!train|test).txt", f, perl=TRUE)) {
              f <- file.path("final", self$language_code, f)
              base_name <- tools::file_path_sans_ext(basename(f))
              trn_path <- file.path(dirname(f), paste0(base_name, ".train.txt"))
              tst_path <- file.path(dirname(f), paste0(base_name, ".test.txt"))
              cond1 <- !(file.exists(trn_path) && file.exists(tst_path))
              if (cond1 || self$replace) {
                text <- read_lines(f)
                set.seed(self$seed); prob <- self$sample_prob
                in_trn <- rbinom(n = length(text), size = 1, prob = prob)
                fwrite(list(text[as.logical(in_trn)]), trn_path, quote = FALSE)
                fwrite(list(text[!as.logical(in_trn)]), tst_path, quote = FALSE)
              }
            }
          }
          
          # "\u302A\u302D\u302E\u302E\u302B\u302C" - forbidden token
          print("reading training data...")
          files <- list.files(file.path("final", self$language_code))
          fulltext <- unlist(lapply(files, function(f) {
            if (grepl(pattern = "\\.train\\.txt", f, perl=TRUE)) {
              read_lines(file.path("final", self$language_code, f))
            }
          }), use.names = FALSE)
          
          print("building corpus...")
          corp <- corpus(fulltext)
          save(corp, file = corp_path)
          private$.corpus <- corp; rm(corp); gc(FALSE)
          private$.corpus
        }
      }
    } else {
      stop("`$corpus` is read-only")
    }
  },
  
  tokens = function(value) {
    if (missing(value)) {
      if (!is.null(private$.tokens) && !self$replace) {
        private$.tokens
      } else {
        tok_path <- file.path("final", self$language_code, "tokens.Rdata")
        if (file.exists(tok_path) && !self$replace) {
          print(sprintf("loading tokens from %s", tok_path))
          load(file = tok_path)
          private$.tokens <- tok; rm(tok); gc(FALSE)
          private$.tokens
        } else {
          corp <- self$corpus
          print("tokenizing and filtering corpus...")
          tok <- tokenize_and_filter(corp, self$filters, self$language_code)
          save(tok, file = tok_path)
          private$.tokens <- tok; rm(tok); gc(FALSE)
          private$.tokens
        }
      }
    } else {
      stop("`$tokens` is read-only")
    }
  },
  
  features = function(value) {
    if (missing(value)) {
      if (!is.null(private$.features) && !self$replace) {
        private$.features
      } else {
        features_name <- sprintf("features.%sgrams.Rdata", self$n)
        features_path <- file.path("final", self$language_code, features_name)
        if (file.exists(features_path) && !self$replace) {
          print(sprintf("loading features from %s", features_path))
          load(file = features_path)
          private$.features <- features; rm(features); gc(FALSE)
          private$.features
        } else {
          tok <- self$tokens
          if (self$n == 1) {
            tok
          } else {
            print("calculating features...")
            features <- tok %>% tokens_ngrams(n = self$n, concatenator = " ")
            save(features, file = features_path)
            private$.features <- features; rm(features); gc(FALSE)
            private$.features
          }
        }
      }
    } else {
      stop("`$features` is read-only")
    }
  },
  
  featurecounts = function(value) {
    if (missing(value)) {
      if (!is.null(private$.featurecounts) && !self$replace) {
        private$.featurecounts
      } else {
        featurecounts_name <- sprintf("featurecounts.%sgrams.Rdata", self$n)
        featurecounts_path <- file.path("final", self$language_code, 
                                        featurecounts_name)
        if (file.exists(featurecounts_path) && !self$replace) {
          print(sprintf("loading feature counts from %s", featurecounts_path))
          load(file = featurecounts_path)
          private$.featurecounts <- counts; rm(counts); gc(FALSE)
          private$.featurecounts
        } else {
          features <- self$features
          print("calculating feature counts...")
          counts <- colSums(features %>%
                              tokens_group(groups = rep("all", ndoc(.))) %>%
                              dfm(verbose = FALSE))
          
          save(counts, file = featurecounts_path)
          private$.featurecounts <- counts; rm(counts); gc(FALSE)
          private$.featurecounts
        }
      }
    } else {
      stop("`$featurecounts` is read-only")
    }
  },
  
  gt_counts = function(value) {
    if (missing(value)) {
      if (!is.null(private$.gt_counts) && !self$replace) {
        private$.gt_counts
      } else {
        print("computing Good-Turing counts...")
        if (!is.null(private$.table) && !self$replace) {
          rawcounts <- self$table[, count]
        } else {
          rawcounts <- self$featurecounts
        }
        counts <- as.data.table(table(rawcounts))
        names(counts) <- c("r", "nr")
        counts[, r := as.numeric(r)]
        counts[, q := shift(r, 1, type = "lag", fill = 0)]
        counts[, t := shift(r, 1, type = "lead", fill = 2 * max(r) - max(q))]
        counts[, logr := log(r)]
        counts[, logZ := log(nr / (0.5 * (t - q)))]
        setkey(counts, r)
        fit <- with(counts, lm(logZ ~ logr))
        
        use_LGT <- FALSE
        b <- as.numeric(fit$coefficients[2])
        if (b > -1) stop(sprintf("LGT not applicable (b > -1): %s", b))
        max_r <- max(counts$r)
        rstar <- sapply(counts$r, function(r) {
          LGT <- r * (1 + 1 / r) ^ (b + 1)
          if (r == max_r || use_LGT) {
            LGT
          } else {
            nr <- counts[eval(.(r)), nr]
            nr1 <- counts[eval(.(r + 1)), nr]
            Turing <- (r + 1) * (nr1 / nr)
            stddev <- sqrt((r + 1)^2 * (nr / nr1) * (1 + nr1 / nr))
            if (abs(LGT - Turing) > 1.65 * stddev) {
              Turing
            } else {
              use_LGT <<- TRUE
              LGT
            }
          }
          # no need to renormalize
        })
        
        private$.gt_counts <- data.table(r = counts$r, nr = counts$nr, 
                                         rstar = rstar, key = "r")
        private$.gt_counts
      }
    } else {
      stop("`$gt_counts` is read-only")
    }
  },
  
  table = function(value) {
    if (missing(value)) {
      # Check if cached:
      if (!is.null(private$.table) & !self$replace) {
        private$.table
      } else {
        table_name <- sprintf("%sgrams.csv", self$n)
        table_path <- file.path("final", self$language_code, table_name)
        
        # Check if saved to disk: 
        if (file.exists(table_path) & !self$replace) {
          print(sprintf("loading table from %s", table_path))
          tab <- fread(file = table_path, data.table = TRUE)
          if (self$min_threshold > 1) tab <- tab[count >= self$min_threshold]
          if (self$n == 1) {
            tab <- tab[order(-count)]
          } else {
            if (self$max_rank == Inf) {
              tab <- tab[order(-count)]
            } else {
              tab <- tab[order(-count), .SD[1:min(nrow(.SD), self$max_rank)], 
                         by = history]
            }
            setkey(tab, history)
          }
          private$.table <- tab; rm(tab); gc(FALSE)
          private$.table
        } else {
          counts <- self$featurecounts
          
          # Build raw count table:
          print("arranging count table...")
          if (self$n == 1) {
            ngram_tab <- data.table(token = names(counts), count = counts)
            rm(counts); gc(FALSE)
          } else {
            ngram_tab <- data.table(feature = names(counts), count = counts)
            rm(counts); gc(FALSE)
            ngram_tab[, paste0("token.", 1:self$n) := tstrsplit(feature, " ")]
            ngram_tab[, history := do.call(paste, .SD),
                      .SDcols = paste0("token.", 1:(self$n - 1))]
            setnames(ngram_tab, paste0("token.", self$n), "token")
            ngram_tab[, c("feature", paste0("token.", 1:(self$n - 1))) := NULL]
            setcolorder(ngram_tab, c("history", "token", "count"))
          }
          
          # Append Good-Turing adjusted counts:
          gt <- self$gt_counts[, .(r, rstar)]
          setnames(gt, "r", "count")
          setnames(gt, "rstar", "gt.count")
          ngram_tab <- ngram_tab[gt, on = "count"]
          
          # Append Kneser-Ney continuation counts for unigrams:
          if (self$n == 1) {
            print("loading bigrams for Kneser-Ney continuation counts...")
            bigram_frequencies <- ngrams$new("en_US", n = 2, min_threshold = 1, 
                                             max_rank = Inf)$table
            print("computing continuation counts...")
            kn <- as.data.table(table(bigram_frequencies[, token]))
            names(kn) <- c("token", "kn.count")
            ngram_tab <- ngram_tab[kn, on = "token", nomatch = 0]
          }
          
          # Save to disk:
          fwrite(ngram_tab, file = table_path)
          ngram_tab <- ngram_tab[count >= self$min_threshold]
          if (self$n == 1) {
            setkey(ngram_tab, token)
          } else {
            if (self$max_rank == Inf) {
              ngram_tab <- ngram_tab[order(-count)]
            } else {
              ngram_tab <- ngram_tab[order(-count), 
                                     .SD[1:min(nrow(.SD), self$max_rank)],
                                     by = history]
            }
            setkey(ngram_tab, history)
          }
          private$.table <- ngram_tab; rm(ngram_tab); gc(FALSE)
          private$.table
        }
      }
    } else {
      stop("`$table` is read-only")
    }
  }
))


predictor <- R6Class("predictor", public = list(
  language_code = NA,
  max_n = NA,
  min_threshold = NA,
  max_rank = NA,
  tables = NULL,
  katz_coefs = NULL,
  gt_counts = NULL,
  filters = NULL,
  
  initialize = function(language_code, max_n = 5, min_threshold = 3, 
                        max_rank = Inf, 
                        filters = c("punctuation", "symbols", "numbers",
                                    "noletters")) {
    stopifnot(is.character(language_code), length(language_code) == 1, 
              dir.exists(file.path("final", language_code)))
    stopifnot(is.numeric(max_n), length(max_n) == 1, max_n > 1, max_n <= 5)
    stopifnot(is.numeric(min_threshold), length(min_threshold) == 1, 
              min_threshold >= 1)
    stopifnot(is.numeric(max_rank), length(max_rank) == 1, max_rank >= 1)
    stopifnot(is.character(filters), 
              all(sapply(filters, function(f) f %in% available_filters)))
    
    self$language_code <- language_code
    self$max_n <- as.integer(max_n)
    self$min_threshold <- as.integer(min_threshold)
    self$max_rank <- max_rank
    self$filters <- filters
    self$tables <- lapply(1:max_n, function(i) {
      ngrams$new(self$language_code, n = i, min_threshold = self$min_threshold, 
                 max_rank = self$max_rank, filters = self$filters)$table
    })
    self$katz_coefs <- lapply(2:max_n, private$katz_coefficients)
    
    setNumericRounding(1)
    self$gt_counts <- lapply(self$tables, function(tab) {
      unique(tab[, .(gt.count), keyby = count])
    })
    setNumericRounding(0)
    
    for (tab in self$tables) {
      tab[, gt.count := NULL]
    }
  },
  
  maximum_likelihood = function(history) {
    history <- private$filter_history(history)
    if (history == "") {
      tab <- self$tables[[1]][, .(token, count)]
    } else {
      n <- length(strsplit(history, " ")[[1]]); stopifnot(n < self$max_n)
      tab <- self$tables[[n + 1]][history, .(token, count)]
    }
    tab[order(-count), .(token, prob = count / sum(count))]
  },
  
  laplace = function(history) {
    history <- private$filter_history(history)
    if (history == "") {
      self$tables[[1]][order(-count), 
                       .(token, prob = (count + 1) / sum(count + 1))]
    } else {
      n <- length(strsplit(history, " ")[[1]]); stopifnot(n < self$max_n)
      tab <- self$tables[[n + 1]][history, .(token, count)]
      unigrams <- self$tables[[1]][order(-count), .(token)]
      merged <- tab[unigrams, on = "token"]
      merged[is.na(count), count := 0]
      merged[order(-count), .(token, prob = (count + 1) / sum(count + 1))]
    }
  },
  
  good_turing = function(history) {
    history <- private$filter_history(history)
    unigrams <- private$append_gt_counts(self$tables[[1]], 1)
    if (history == "") {
      unigrams <- unigrams[order(-gt.count), 
                           .(token, prob = gt.count / sum(count))]
      unk <- data.table(token = "<UNK>", prob = 1 - sum(unigrams[, prob]))
      rbindlist(list(unigrams, unk))
    } else {
      n <- length(strsplit(history, " ")[[1]]); stopifnot(n < self$max_n)
      tab <- private$append_gt_counts(self$tables[[n + 1]][history], n + 1)
      tab <- tab[order(-gt.count), .(token, prob = gt.count / sum(count))]
      leftover <- 1 - sum(tab[, prob], na.rm = TRUE)
      unigrams <- unigrams[order(-gt.count), 
                           .(token, prob = leftover / nrow(.SD))]
      rbindlist(list(tab, unigrams[!(token %in% tab[, token])]))
    }
  },
  
  jelinek_mercer = function(history, lambda = 0.1) {
    history <- private$filter_history(history)
    if (history == "") {
      self$tables[[1]][order(-count), .(token, prob = count / sum(count))]
    } else {
      split <- strsplit(history, " ")[[1]]
      n <- length(split); stopifnot(n < self$max_n)
      short_history <- ifelse(n == 1, "", paste(split[2:n], collapse = " "))
      
      previous <- self$jelinek_mercer(short_history, lambda = lambda)
      current <- self$tables[[n + 1]][history, 
                                      .(token, prob = count / sum(count))]
      merged <- current[previous, on = "token"]; rm(current, previous)
      merged[is.na(prob), prob := 0]
      merged[, prob := (1 - lambda) * prob + lambda * i.prob]
      merged[order(-prob), .(token, prob)]
    }
  },
  
  katz_backoff = function(history, backoff_coef = NA) {
    history <- private$filter_history(history)
    if (history == "") {
      unigrams <- private$append_gt_counts(self$tables[[1]], 1)
      unigrams[order(-gt.count), .(token, prob = gt.count / sum(count))]
    } else {
      split <- strsplit(history, " ")[[1]]
      n <- length(split); stopifnot(n < self$max_n)
      
      current <- private$append_gt_counts(self$tables[[n + 1]][history, 
                                                               nomatch = NULL], 
                                          n + 1)
      current <- current[order(-gt.count), 
                         .(token, prob = gt.count / sum(count))]
      if (nrow(current) > 0) { # match found
        if (!is.na(backoff_coef)) {
          current[, prob := backoff_coef * prob]
        }
        leftover_prob <- 1 - sum(current[, prob])
        unigrams <- private$append_gt_counts(self$tables[[1]], 1)
        unigrams <- unigrams[order(-gt.count), 
                             .(token, prob = leftover_prob / nrow(.SD))]
        rbindlist(list(current, unigrams[!(token %in% current[, token])]))
      } else {
        short_history <- ifelse(n == 1, "", paste(split[2:n], collapse = " "))
        coef <- self$katz_coefs[[n]][history, katz.coef]
        self$katz_backoff(short_history, coef)
      }
    }
  },
  
  kneser_ney = function(history, delta = 0.5) {
    stopifnot(is.numeric(delta), length(delta) == 1, delta >= 0, delta <= 1)
    history <- private$filter_history(history)
    if (history == "") {
      self$tables[[1]][order(-kn.count), 
                       .(token, prob = kn.count / sum(kn.count))]
    } else {
      split <- strsplit(history, " ")[[1]]
      n <- length(split); stopifnot(n < self$max_n)
      short_history <- ifelse(n == 1, "", paste(split[2:n], collapse = " "))
      
      previous <- self$kneser_ney(short_history, delta = delta)
      current <- self$tables[[n + 1]][history, .(count, 
                                      discounted = max(count - delta, 0)),
                                      by = token]
      current[, prob := discounted / sum(count)]
      interp_coef <- delta * nrow(current) / sum(current[, count])
      
      merged <- current[previous, .(token, prob, i.prob), on = "token"]
      rm(previous, current)
      merged[is.na(prob), prob := 0]
      if (is.na(interp_coef)) interp_coef <- 1
      merged[, prob := prob + interp_coef * i.prob]
      merged[order(-prob), .(token, prob)]
    }
  },
  
  stupid_backoff = function(history, alpha = 0.4, recursion_depth = 0) {
    history <- private$filter_history(history)
    if (history == "") {
      unigrams <- self$tables[[1]][, .(token, score = count / sum(count))]
      if (recursion_depth > 0) unigrams[, score := alpha * score]
      unigrams[order(-score)]
    } else {
      split <- strsplit(history, " ")[[1]]
      n <- length(split); stopifnot(n < self$max_n)
      
      current <- self$tables[[n + 1]][history, 
                                      .(token, score = count / sum(count)),
                                      nomatch = NULL]
      if (nrow(current) > 0) {
        if (recursion_depth > 0) current[, score := alpha * score]
        current[order(-score)]
      } else {
        short_history <- ifelse(n == 1, "", paste(split[2:n], collapse = " "))
        self$stupid_backoff(short_history, alpha = alpha, 
                            recursion_depth = recursion_depth + 1)
      }
    }
  },
  
  save = function() {
    model_dir <- file.path("models")
    if (!dir.exists(model_dir)) dir.create(model_dir)
    thresh_dir <- file.path(model_dir, sprintf("thresh%s", self$min_threshold))
    if (!dir.exists(thresh_dir)) dir.create(thresh_dir)
    name <- sprintf("thresh%s.max%s.Rdata", self$min_threshold, self$max_rank)
    p <- self
    save(p, file = file.path(thresh_dir, name))
  }
),

private = list(
  katz_coefficients = function(n) {
    print(sprintf("calculating Katz Backoff coefficients for n = %s...", n))
    stopifnot(n > 1, n <= self$max_n)
    tab <- self$tables[[n]][, 
                            .(token, gt.prob = gt.count / sum(count)), by = history]
    
    if (n - 1 == 1) {
      prev_tab <- self$tables[[n - 1]][, 
                                       .(token, prev.gt = gt.count / sum(count))]
    } else {
      prev_tab <- self$tables[[n - 1]][,
                                       .(token, prev.gt = gt.count / sum(count)), by = history]
      setnames(prev_tab, "history", "short.hist")
    }
    
    if (n - 1 == 1) {
      tab <- tab[prev_tab, on = "token"]
    } else {
      # Create short.hist column in current tab and join:
      tab[, paste0("token.", 1:(n - 1)) := tstrsplit(history, " ")]
      tab[, short.hist := do.call(paste, .SD), 
          .SDcols = paste0("token.", 2:(n - 1))]
      tab <- tab[prev_tab, .(history, token, gt.prob, prev.gt), 
                 on = .(short.hist, token)]
      #tab[, c("short.hist", paste0("token.", 1:(n - 1))) := NULL]
    }
    rm(prev_tab); gc(FALSE)
    
    tab[, .(katz.coef = (1 - sum(gt.prob)) / (1 - sum(prev.gt))), 
        keyby = history]
  },
  
  append_gt_counts = function(tab, n) {
    res <- tab[self$gt_counts[[n]], on = "count", nomatch = NULL]
    if (n == 1) {
      res[order(-count)]
    } else {
      setkey(res, history)
      res
    }
  },
  
  filter_history = function(history) {
    separated <- tokenize_and_filter(history, self$filters, self$language_code)
    last_sentence <- as.character(tail(separated, 1))
    last_feature <- tail(last_sentence, self$max_n - 1)
    paste(last_feature, collapse = " ")
  }
))