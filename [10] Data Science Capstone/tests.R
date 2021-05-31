source("text_predictor.R")


accuracy <- function(test_predictor, method = "Stupid Backoff",
                     sample_prob = 0.01, seed = 12345,
                     filters = c("punctuation", "symbols", "numbers",
                                 "noletters")) {
  valid_methods <- c("Maximum Likelihood", "Laplace", "Good-Turing",
                     "Jelinek-Mercer", "Katz Backoff", "Kneser-Ney", 
                     "Stupid Backoff")
  stopifnot(method %in% valid_methods)
  
  setDTthreads(0)
  test_tab <- test_table(language_code = test_predictor$language_code,
                         max_n = test_predictor$max_n,
                         sample_prob = sample_prob,
                         seed = seed,
                         filters = filters)
  
  top5 <- function(history, group_num) {
    cat(sprintf("progress: %.1f%%\r", group_num / ngrp * 100))
    if(method == "Maximum Likelihood") {
      result <- test_predictor$maximum_likelihood(history)[, token]
    } else if (method == "Laplace") {
      result <- test_predictor$laplace(history)[, token]
    } else if (method == "Good-Turing") {
      result <- test_predictor$good_turing(history)[, token]
    } else if (method == "Jelinek-Mercer") {
      result <- test_predictor$jelinek_mercer(history)[, token]
    } else if (method == "Katz Backoff") {
      result <- test_predictor$katz_backoff(history)[, token]
    } else if (method == "Kneser-Ney") {
      result <- test_predictor$kneser_ney(history)[, token]
    } else if (method == "Stupid Backoff") {
      result <- test_predictor$stupid_backoff(history)[, token]
    }
    
    list(prediction.1 = result[1],
         prediction.2 = result[2],
         prediction.3 = result[3],
         prediction.4 = result[4],
         prediction.5 = result[5])
  }
  
  print("generating predictions...")
  ngrp <- uniqueN(test_tab$history)
  test_tab[, paste0("prediction.", 1:5) := top5(history, .GRP), by = history]
  
  print("tabulating results...")
  acc1 <- mean(test_tab[, correct %in% prediction.1, 
                        by = seq_len(nrow(test_tab))][[2]])
  acc3 <- mean(test_tab[, correct %in% c(prediction.1, 
                                         prediction.2, 
                                         prediction.3), 
                        by = seq_len(nrow(test_tab))][[2]])
  acc5 <- mean(test_tab[, correct %in% c(prediction.1,
                                         prediction.2,
                                         prediction.3,
                                         prediction.4,
                                         prediction.5),
                        by = seq_len(nrow(test_tab))][[2]])
  data.table(top1 = acc1, top3 = acc3, top5 = acc5, N = nrow(test_tab))
}

test_table <- function(language_code, max_n, sample_prob = 0.01, seed = 12345,
                       filters = c("punctuation", "symbols", "numbers",
                                   "noletters")) {
  print("reading testing data...")
  files <- list.files(file.path("final", language_code))
  test_lines <- unlist(lapply(files, function(f) {
    if (grepl(pattern = "\\.test\\.txt", f, perl=TRUE)) {
      read_lines(file.path("final", language_code, f))
    }
  }), use.names = FALSE)
  
  print("building test table...")
  set.seed(seed)
  test_lines <- sample(test_lines, size = sample_prob * length(test_lines))
  test_tokens <- tokenize_and_filter(test_lines, filters, language_code)
  
  get_histories <- function(tok, max_n) {
    if (length(tok) == 1) {return(NA)}
    as.character(sapply(seq_along(head(tok, length(tok) - 1)), function(i) {
      if (i < max_n) {
        paste(tok[1:i], collapse = " ")
      } else {
        paste(tok[(i - max_n + 1):i], collapse = " ")
      }
    }))
  }
  
  get_correct <- function(tok) {
    if (length(tok) == 1) {return(NA)}
    as.character(sapply(seq_along(head(tok, length(tok) - 1)), function(i) {
      tok[i + 1]
    }))
  }
  
  prediction_table <- data.table()
  for (sentence in as.list(test_tokens)) {
    sentence <- as.character(sentence)
    prediction_table <- rbindlist(
      list(prediction_table,
           data.table(history = get_histories(sentence, max_n - 1),
                      correct = get_correct(sentence))
      )
    )
  }
  prediction_table[!is.na(correct)]
}

compile_accuracy <- function() {
  acc_paths <- c("accuracy.maximumlikelihood.Rdata",
                 "accuracy.laplace.Rdata",
                 "accuracy.goodturing.Rdata",
                 "accuracy.jelinekmercer.Rdata",
                 "accuracy.katzbackoff.Rdata",
                 "accuracy.kneserney.Rdata",
                 "accuracy.stupidbackoff.Rdata")
  load(acc_paths[1])
  accuracy_table <- t(round(test_results[1, 1:3], 3))
  for (path in acc_paths[2:length(acc_paths)]) {
    load(path)
    accuracy_table <- cbind(accuracy_table, t(round(test_results[1, 1:3], 3)))
  }
  accuracy_table <- data.frame(accuracy_table)
  colnames(accuracy_table) <- c("Maximum Likelihood", "Laplace", "Good-Turing",
                                "Jelinek-Mercer", "Katz Backoff", "Kneser-Ney",
                                "Stupid Backoff")
  rownames(accuracy_table) <- c("Top1", "Top3", "Top5")
  fwrite(accuracy_table, file = "accuracy.csv", row.names = TRUE)
  accuracy_table
}

test_load_memory_leaks <- function(times = 10) {
  for (i in seq(times)) {
    load(file = file.path("thresh2.maxInf.Rdata"))
    rm(p); gc(FALSE)
  }
}

pick_best <- function(p, query, choices) {
  result <- p$kneser_ney(query); setkey(result, token)
  sort(sapply(choices, function(ch) result[ch, prob]), decreasing = TRUE)
}
