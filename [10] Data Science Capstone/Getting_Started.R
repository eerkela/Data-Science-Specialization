# Download data:
if (!file.exists("final")) {
  dat_url <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
  dest_file <- "Coursera-Swiftkey.zip"
  download.file(dat_url, dest_file)
  unzip(dest_file)
  file.remove(dest_file)
  
  # Clean up workspace:
  rm(dat_url)
  rm(dest_file)
}

# Create random subsample:
build_subsample <- function(path, prob=0.3) {
  set.seed(1234)
  read_connection <- file(path, "r")
  in_sample <- vector()
  for (line in readLines(read_connection)) {
    if (rbinom(n=1, size=1, prob=prob)) {
      in_sample <- c(in_sample, line)
    }
  }
  output_name <- tools::file_path_sans_ext(basename(path))
  output_file <- file.path(dirname(path), paste0(output_name, ".sample.txt"))
  write_connection <- file(output_file)
  writeLines(in_sample, write_connection)
  close(write_connection)
}

# Tokenization:
require("quanteda")
tokenize <- function(path) {
  connection <- file(path, "r")
  text <- readLines(connection)
  tokenized <- tokens(text)
  close(connection)
  tokenized
}

# Profanity Filtering:
filter_profanity <- function(char_vec) {
  # using a list of 1300 profane words compiled by Carnegie Mellon University:
  if (!file.exists("profanity_list.txt")) {
    profanity_url <- "https://www.cs.cmu.edu/~biglou/resources/bad-words.txt"
    download.file(profanity_url, "profanity_list.txt")
    rm(profanity_url)
  }
  profanity_list <- readLines("profanity_list.txt")
  gsub(paste(unlist(profanity_list), collapse="|"), replacement="", x=char_vec)
}

build_subsample(file.path("final", "en_US", "en_US.twitter.txt"))
build_subsample(file.path("final", "en_US", "en_US.blogs.txt"))
build_subsample(file.path("final", "en_US", "en_US.news.txt"))




## Quiz 1
en_us_twitter_path <- file.path("final", "en_US", "en_US.twitter.txt")
en_us_blogs_path <- file.path("final", "en_US", "en_US.blogs.txt")
en_us_news_path <- file.path("final", "en_US", "en_US.news.txt")

longest_line <- 0
longest_line_group <- ""

conn <- file(en_us_twitter_path, "r")
size <- 0
love <- 0
hate <- 0
match_phrase <- "A computer once beat me at chess, but it was no match for me at kickboxing"
num_matches <- 0
biostats_line <- ""
for (line in readLines(conn)) {
  size <- size + 1
  if (nchar(line) > longest_line) {
    longest_line <- nchar(line)
    longest_line_group <- "Twitter"
  }
  if (grepl("love", line)) {
    love <- love + 1
  }
  if (grepl("hate", line)) {
    hate <- hate + 1
  }
  if (grepl(match_phrase, line)) {
    num_matches <- num_matches + 1
  }
  if (grepl("biostats", line)) {
    biostats_line <- line
  }
}
close(conn)
paste("# of lines in twitter dataset:", size)
paste("# of lines containing love / # of lines containing hate:", love/hate)
paste("line mentioning biostats:", biostats_line)

conn <- file(en_us_blogs_path, "r")
for (line in readLines(conn)) {
  if (nchar(line) > longest_line) {
    longest_line <- nchar(line)
    longest_line_group <- "blogs"
  }
}
close(conn)

conn <- file(en_us_news_path, "r")
for (line in readLines(conn)) {
  if (nchar(line) > longest_line) {
    longest_line <- nchar(line)
    longest_line_group <- "news"
  }
}
close(conn)
paste("# of chars in longest line:", longest_line, "in", longest_line_group)
