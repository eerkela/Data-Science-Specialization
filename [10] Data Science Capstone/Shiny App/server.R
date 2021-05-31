library(gdata, include.only = "humanReadable")
library(ggplot2)
library(pryr, include.only = "mem_used")
library(shiny)
library(shinyjs, include.only = c("toggle", "toggleState"))
library(wordcloud2)

source("text_predictor.R")


get_smoothing_description <- function(smoothing_method) {
    if (smoothing_method == "Maximum Likelihood") {
        renderUI(
            withMathJax(
                tags$h3("\\(n-\\text{gram}\\) Language Models"),
                tags$p(
                    paste0(
                        "Generally speaking, statistical language models ",
                        "are concerned with assigning probabilities to ",
                        "sentences or particular sequences of words within a ",
                        "corpus of text, which ideally represents natural, ",
                        "unstructured language to the greatest extent ",
                        "possible.  To represent this, let ",
                        "\\(w_1^L = (w_1,...,w_L)\\) describe a continuous ",
                        "sequence of \\(L\\) words in a natural language, ",
                        "starting from the first word in the sequence, ",
                        "\\(w_1\\), and ending at its final one, \\(w_L\\).  ",
                        "An incremental language model assigns a fixed ",
                        "probability to \\(w_1^L\\) according to the ",
                        "following expression: ",
                        "$$P(w_1^L) = P(w_1, w_2, w_3, ..., w_L) ",
                        "= P(w_L|w_1,w_2,...,w_{L-1})$$",
                        "Which represents the chance \\(w_L\\) occurs given ",
                        "the history \\(w_1, w_2, ..., w_{L-1}\\)."
                    )
                ),
                tags$p(
                    paste0(
                        "Using the chain rule of probability, we can expand ",
                        "this definition to",
                        "$$P(w_L|w_1,w_2,...,w_{L-1}) = ",
                        "P(w_1)P(w_2|w_1)P(w_3|w_2,w_1)...P(w_L|w_1^{L-1}) = ",
                        "\\Pi_{i=1}^LP(w_i|w_1^{i-1})$$",
                        "Which theoretically allows us to perform exact ",
                        "calculations of probability for arbitrary sequences ",
                        "of words.  This expression has a number of ",
                        "shortcomings, however, not the least of which is ",
                        "that faithfully evaluating it requires complete ",
                        "knowledge of *all* the conditional probabilities ",
                        "involved in representing a natural language (which ",
                        "is an impossibility), and evaluating it for ",
                        "large phrases becomes computationally inefficient ",
                        "very quickly.  In fact, a linear increase in \\(L\\) ",
                        "is associated an exponential increase in ",
                        "\\(w_1^L\\).  As such, the best we can hope for is ",
                        "a good approximation."
                    )
                ),
                tags$p(
                    paste0(
                        "An \\(n-\\text{gram}\\) approach accomplishes this ",
                        "approximation by modeling each sequence of words as ",
                        "a Markov chain, which assumes that most of the ",
                        "information needed to predict future words in the ",
                        "sequence is encoded the \\(n-1\\) most ",
                        "recent words (\\(w_{i-n+1}^{i-1}\\)) rather than ",
                        "the full history up to that point (\\(w_1^i\\)).  ",
                        "Formally, this approximation can be written as",
                        "$$P(w_i|w_1^{i-1}) \\approx P(w_i|w_{i-n+1}^{i-1})$$",
                        "Which, provided a reasonable choice of \\(n\\), ",
                        "greatly simplifies our calculations and allows us ",
                        "to safely discard the first \\((L - n)\\) tokens in ",
                        "each sentence without losing predictive capacity."
                    )
                ),
                tags$h3("Maximum Likelihood Word Prediction"),
                tags$p(
                    paste0(
                        "Like every other statistical language model, the ",
                        "Maximum Likelihood method assigns a particular form ",
                        "of probability measure to each \\(n-\\text{gram}\\), ",
                        "\\(w_{i-n+1}^i\\), observed in the base corpus.  ",
                        "In the case of Maximum Likelihood, this probability ",
                        "measure looks like this:",
                        "$$P_{MLE}(w_i|w_{i-n+1}^{i-1}) = ",
                        "\\frac{C(w_{i-n+1}^{i-1}w_i)}",
                        "{\\Sigma_{w_i}C(w_{i-n+1}^{i-1}w_i)} = ",
                        "\\frac{C(w_{i-n+1}^i)}{C(w_{i-n+1}^{i-1})}$$",
                        "Where \\(C(x)\\) represents the count of \\(x\\) ",
                        "across the corpus used to create the model."
                    )
                ),
                tags$p(
                    paste0(
                        "This intuitively correlates to the proportion of ",
                        "times a specific \\(w_i\\) occurs following the ",
                        "sequence \\(w_{i-n+1}^{i-1}\\), given all the ",
                        "other possible \\(w_i\\) which have been observed to ",
                        "do so.  As such, this is a straightforward ",
                        "proportion, which is both simple to understand and ",
                        "implement.  However, what happens if we input a ",
                        "sequence that is never actually observed to occur ",
                        "in the original corpus?  In that case, our counts ",
                        "compute to \\(0\\) and the Maximum Likelihood method ",
                        "fails to return a result entirely.  What makes this ",
                        "even worse is that there are a practically ",
                        "infinite number of such phrases, owing to the fact ",
                        "that no corpus, no matter how large, can fully ",
                        "encapsulate every possible facet of a target language."
                    )
                ),
                tags$p(
                    paste0(
                        "To address this, we need a way of including ",
                        "sequences of words that we haven't explicitly seen ",
                        "before into our language model.  This is the essence ",
                        "of smoothing and is what this tool is designed to ",
                        "help explore."
                    )
                )           
            )
        )
    }
    else if(smoothing_method == "Laplace") {
        renderUI(
            withMathJax(
                tags$h3("Laplace (Additive) Smoothing"),
                tags$p(
                    paste0(
                        "The first effective smoothing technique to be ",
                        "developed for unconstrained data comes from none ",
                        "other than Pierre-Simon Laplace, who developed it ",
                        "while trying to work out the so-called sunrise ",
                        "problem, where one estimates the chance that the ",
                        "sun will rise tomorrow given incomplete knowledge ",
                        "of the future."
                    )
                ),
                tags$p(
                    paste0(
                        "Laplace's method was to consider a hypothetical ",
                        "future occurrence of each possibility (in this case, ",
                        "the presence/absence of the sun) in relation to the ",
                        "body of data we had hitherto collected. When doing ",
                        "so, a hypothetical morning in which the sun did not ",
                        "rise would represent an event which occurs with ",
                        "probability ",
                        "$$\\frac{1}",
                        "{\\text{total # of mornings with a sunrise} + 1}$$",
                        "Since this represents the hypothetical possibility ",
                        "of a sunless morning, we can take this value to be ",
                        "an adequate estimation of the actual probability of ",
                        "observing a previously unobserved event, barring ",
                        "outside knowledge which could definitively preclude ",
                        "the event."
                    )
                ),
                tags$p(
                    paste0(
                        "In practice, Laplace's method equates to defining a ",
                        "pseudocount which we will consider in place of the ",
                        "actual observed counts in our Maximum Likelihood ",
                        "calculations.  In the Laplacian case, this ",
                        "pseudocount is simply equivalent to ",
                        "$$C_{Laplace}(w_i) = C(w_i) + 1$$",
                        "Which gives the following probability measure:",
                        "$$P_{Laplace}(w_i|w_{i-n+1}^{i-1}) = ",
                        "\\frac{C(w_{i-n+1}^i) + 1}",
                        "{\\Sigma_{w_i}[C(w_{i-n+1}^{i-1}w_i) + 1]} = ",
                        "\\frac{C(w_{i-n+1}^i) + 1}",
                        "{C(w_{i-n+1}^{i-1}) + |V|}$$",
                        "Note that now, when we input a phrase which has an ",
                        "observed count of \\(0\\), we don't have any ",
                        "problems, and simply get an a probability of ",
                        "\\(1/|V|\\), the inverse of the size of our corpus."
                    )
                ),
                tags$p(
                    paste0(
                        "The eagle-eyed may notice similarities in Laplace's ",
                        "approach and Bayesian statistics, and that is not by ",
                        "accident.  In fact, Additive smoothing with varying ",
                        "definitions of psuedocounts can be used to represent ",
                        "practically any Bayesian prior distribution by ",
                        "effectively appending the prior to the observations. ",
                        "The choice to add one in Laplace's method thus ",
                        "corresponds to the assumption of a uniform prior ",
                        "where each hypothetical possibility is equally ",
                        "weighted.  In the context of NLP, this means we are ",
                        "modeling each feature as happening with equal ",
                        "frequency in unstructured language, which is an ",
                        "obvious absurdity.  Still, this method technically ",
                        "allows us to obtain predictions even in cases we may ",
                        "have never encountered before, which is a massive ",
                        "step up from Maximum Likelihood."
                    )
                )
            )
        )
    }
    else if (smoothing_method == "Good-Turing") {
        renderUI(
            withMathJax(
                tags$h3("Good-Turing Smoothing"),
                tags$p(
                    paste0(
                        "The second major smoothing algorithm - Good-Turing - ",
                        "attempts to derive its prior knowledge from the data ",
                        "itself rather than relying on external pseudocounts ",
                        "like additive smoothing.  To do this, the ",
                        "Good-Turing method redistributes some of the ",
                        "observed counts such that probability mass is ",
                        "reallocated from rare events to those that were ",
                        "never observed at all.  To demonstrate this, let ",
                        "\\(N\\) be the total number of observed ",
                        "\\(n-\\text{grams}\\) in a sample corpus, and let ",
                        "\\(n_r\\) be the number of \\(n-\\text{grams}\\) ",
                        "that occur exactly \\(r\\) times within it, such that",
                        "$$N = \\Sigma_{r=1}^{\\infty}rn_r$$",
                        "Then, for each count \\(r\\), we compute the ",
                        "Good-Turing adjusted count $r^*$ as follows:",
                        "$$r^* = (r + 1) \\frac{n_{r+1}}{n_r}$$",
                        "Note that \\(N\\), the total number of ",
                        "\\(n-\\text{grams}\\) observed, is preserved by this ",
                        "discounting such that ",
                        "$$N = \\Sigma_{r=0}^\\infty r^*n_r = ",
                        "\\Sigma_{r=1}^\\infty rn_r$$",
                        "This conservation of observed counts allows us to ",
                        "proceed in a manner analogous to the Maximum ",
                        "Likelihood case, giving the following measure for ",
                        "the probability of seeing a particular ",
                        "\\(n-\\text{gram}\\) \\(w_{i-n+1}^i\\):",
                        "$$P_{GT}(w_i|w_{i-n+1}^{i-1} : C(w_{i-n+1}^i) = r) ",
                        "= \\frac{r^*}{N}$$",
                        "Combining the 3 equations above yields the following ",
                        "expression for the total probability mass retained ",
                        "by our observed \\(n-\\text{grams}\\)",
                        "$$\\begin{equation}",
                        "\\begin{split}",
                        "\\Sigma_{w_{i-n+1}^i: C(w_{i-n+1}^i) > 0}",
                        "P_{GT}(w_{i-n+1}^i) & = \\frac{1}{N} ",
                        "\\Sigma_{r=1}^{\\infty}(r+1)\\frac{n_{r+1}}{n_r} \\ ",
                        "& = \\frac{1}{N}(2n_2 + 3n_3 + ...) \\ ",
                        "& = \\frac{1}{N}(N - n_1) \\ ",
                        "& = 1 - \\frac{n_1}{N} ",
                        "\\end{split} ",
                        "\\end{equation}$$",
                        "Which implies that the leftover probability mass ",
                        "that the Good-Turing algorithm has shifted toward ",
                        "unseen \\(n-\\text{grams}\\) be given by:",
                        "$$\\Sigma_{w_{i-n+1}^i: C(w_{i-n+1}^i) = 0}",
                        "P_{GT}(w_{i-n+1}^i) = \\frac{n_1}{N}$$",
                        "As a result, we can express the complete Good-Turing ",
                        "probability measure as follows:",
                        "$$P_{GT}(w_i|w_{i-n+1}^{i-1} : C(w_{i-n+1}^i) = r) ",
                        "= \\left\\{",
                        "\\begin{array}{11}",
                        "\\frac{n_1}{N} & \\quad \\text{if } r = 0 \\\\",
                        "\\frac{r^*}{N} & \\quad \\text{otherwise}",
                        "\\end{array}",
                        "\\right.$$"
                    )
                ),
                tags$p(
                    paste0(
                        "While Good-Turing has numerous documented problems ",
                        "(particularly at high \\(r\\), where \\(r\\) is ",
                        "especially noisy and/or \\(n_{r+1} = 0\\)), it ",
                        "generally performs better than either the Maximum ",
                        "Likelihood or Laplace methods.  It is missing the ",
                        "sophistication of more recent models, but serves as ",
                        "an adequate basis on which other smoothing methods ",
                        "(particularly Katz Backoff) can build."
                    )
                ),
                tags$h3("Simple Good-Turing"),
                tags$p(
                    paste0(
                        "There does exist an extension of Good-Turing which ",
                        "attempts to shore up some of the problems that occur ",
                        "when \\(r\\) is sparse and noisy.  In this ",
                        "extension, let \\(q\\), \\(r\\), \\(t\\) be ",
                        "consecutive subscripts, for which \\(n_q\\), ",
                        "\\(n_r\\), and \\(n_t\\) are all nonzero.  When ",
                        "\\(r = 1\\), let \\(q = 0\\), and when \\(r\\) is ",
                        "the last nonzero frequency, let \\(t = 2r - q\\).  ",
                        "We then define",
                        "$$Z_r = \\frac{n_r}{0.5(t - q)}$$",
                        "Once these values have been ascertained, both ",
                        "\\(Z_r\\) and \\(r\\) are mapped to log space and ",
                        "fitted via linear regression ",
                        "\\(\\log(Z_r) = a + b\\log(r)\\).  For small values ",
                        "of \\(r\\), both sparsity and noise are constrained, ",
                        "and it is reasonable to reject this fit altogether ",
                        "in favor of the standard definition of \\(n_r\\).  ",
                        "For large \\(r\\), however, values of \\(n_r\\) ",
                        "should be derived from this regression line.  The ",
                        "constant over which this revised measure of ",
                        "\\(n_r\\) ought to be considered is called \\(k\\), ",
                        "and will be referenced again in the context of Katz ",
                        "Backoff smoothing."
                    )
                )
            )
        )
    }
    else if(smoothing_method == "Jelinek-Mercer") {
        renderUI(
            withMathJax(
                tags$h3("Jelinek-Mercer Smoothing"),
                tags$p(
                    paste0(
                        "Jelinek-Mercer represents a fundamentally different ",
                        "approach to the previous models, one significantly ",
                        "more suited to the specific nature of an ",
                        "\\(n-\\text{gram}\\) prediction algorithm.  Just as ",
                        "with other smoothing models, a query string is first",
                        "broken up into its constituent \\(n-\\text{gram}\\)",
                        "features before the final feature is fed into the ",
                        "prediction model itself.  Unlike the other models, ",
                        "however, Jelinek-Mercer continues the processing ",
                        "another step.  After the final \\(n-\\text{gram}\\)",
                        "is fed into the prediction model, Jelinek-Mercer ",
                        "splits this string up into several separate ",
                        "histories, each of which incorporate the last ",
                        "(most recent) \\(n - 1\\) elements from the ",
                        "previous history.  It then queries each of these ",
                        "histories against a Maximum Likelihood frequency ",
                        "table and interpolates (adds) them together to ",
                        "achieve a final result."
                    )
                ),
                tags$p(
                    paste0(
                        "For instance, consider the phrases 'burnish the' and ",
                        "'burnish thou'.  If, in a given corpus, ",
                        "\\(C(\\text{burnish the}) = C(\\text{burnish thou}) ",
                        "= 0\\), then under both additive smoothing and ",
                        "Good-Turing:",
                        "$$P(\\text{the|burnish}) = P(\\text{thou|burnish})$$",
                        "Even though we know the word 'the' occurs with much ",
                        "higher frequency than 'thou' in everyday speech.  ",
                        "As such, we'd expect 'burnish the' to be far more ",
                        "common than 'burnish thou' in a more complete ",
                        "language model.  Luckily, we can emulate this fact ",
                        "by interpolating higher and lower-order models ",
                        "together, such that in a bigram model:",
                        "$$P_{interp}(w_i|w_{i-1}) = ",
                        "\\lambda*P_{MLE}(w_i|w_{i-1}) + ",
                        "(1-\\lambda)*P_{MLE}(w_i)$$",
                        "Where \\(\\lambda\\) is an experimental constant ",
                        "(set in the sidebar to the left) that represents ",
                        "the weighting balance between higher and lower-order ",
                        "models."
                    )
                ),
                tags$p(
                    paste0(
                        "As expected, when we reevaluate the two phrases ",
                        "'burnish the' and 'burnish thou' with this updated ",
                        "probability measure, we get",
                        "$$P(\\text{the|burnish}) > P(\\text{thou|burnish})$$",
                        "Since \\(P_{MLE}(\\text{the}) >> ",
                        "P_{MLE}(\\text{thou})\\) in our corpus.  We can ",
                        "generalize this strategy to any \\(n\\) by defining ",
                        "an \\(n\\)th-order model as a linear combination of ",
                        "the \\(n\\)th-order Maximum Likelihood model and ",
                        "the \\(n-1\\)th-order interpolated model as follows: ",
                        "$$P_{interp}(w_i|w_{i-n+1}^{i-1}) = ",
                        "\\lambda_{w_{i-n+1}^{i-1}} ",
                        "P_{MLE}(w_i|w_{i-n+1}^{i-1}) + ",
                        "(1-\\lambda_{w_{i-n+1}^{i-1}}) ",
                        "P_{interp}(w_i|w_{i-n+2}^{i-1})$$",
                        "Where the recursion is grounded at the first order ",
                        "Maximum Likelihood unigram model, as in the bigram ",
                        "example above."
                    )
                )
            )
        )
    }
    else if (smoothing_method == "Katz Backoff") {
        renderUI(
            withMathJax(
                tags$h3("Katz Backoff Smoothing"),
                tags$p(
                    paste0(
                        "Katz Backoff (and in fact every other advanced ",
                        "smoothing method) involves similar logic to the ",
                        "Jelinek-Mercer approach in that it involves ",
                        "combining results from progressively shorter ",
                        "histories in addition to the one explicitly provided ",
                        "by the user.  In Katz, however, this is not done via ",
                        "interpolation as in Jelinek-Mercer, but by \"backing ",
                        "off\" to a shorter history if and only if a longer ",
                        "one has an observed count of zero across the ",
                        "corpus.  As such, all \"Backoff\" models of this ",
                        "type stop their recursion at the first (longest) ",
                        "history they find that occurs at least once in the ",
                        "training data.  Once such a history is found, the ",
                        "results are evaluated according to Good-Turing ",
                        "probability estimation, and the final predictions ",
                        "are presented to the user.  If none of the histories ",
                        "for a given input phrase are observed to occur ",
                        "anywhere in the corpus, a Good-Turing estimation of ",
                        "unigrams is returned instead."
                    )
                ),
                tags$p(
                    paste0(
                        "Mathematically, this operation yields the following ",
                        "probability measure:",
                        "$$P_{katz}(w_i|w_{i-n+1}^{i-1}) = \\left\\{",
                        "\\begin{array}{11}",
                        "P_{GT}(w_i|w_{i-n+1}^{i-1}) & \\quad ",
                        "\\text{if } C(w_{i-n+1}^i) > 0 \\\\",
                        "\\alpha_{w_{i-n+1}^{i-1}}",
                        "P_{katz}(w_i|w_{i-n+2}^{i-1}) & \\quad ",
                        "\\text{otherwise}",
                        "\\end{array}",
                        "\\right.$$",
                        "Where \\(\\alpha_{w_{i-n+1}^{i-1}}\\) represents a ",
                        "normalizing constant that corrects for the ",
                        "nonlinearities introduced in the backoff approach. ",
                        "To compute these, it is helpful to define another ",
                        "constant \\(\\beta(w_{i-n+1}^{i-1})\\), which ",
                        "represents the probability mass left over from the ",
                        "Good-Turing algorithm for the input phrase ",
                        "\\(w_{i-n+1}^{i-1}\\), such that",
                        "$$\\beta(w_{i-n+1}^{i-1}) = ",
                        "1 - \\Sigma_{w_i:C(w_{i-n+1}^i)>0}",
                        "P_{GT}(w_i|w_{i-n+1}^{i-1})$$",
                        "We then define \\(\\alpha_{w_{i-n+1}^{i-1}}\\) in ",
                        "relation to \\(\\beta(w_{i-n+1}^{i-1})\\) according ",
                        "to",
                        "$$\\begin{equation}",
                        "\\begin{split}",
                        "\\alpha_{w_{i-n+1}^{i-1}} & = ",
                        "\\frac{\\beta(w_{i-n+1}^{i-1})}",
                        "{\\Sigma_{w_i:C(w_{i-n+1}^i)>0}",
                        "P_{katz}(w_i|w_{i-n+2}^{i-1})} \\",
                        "& = \\frac{1 - \\Sigma_{w_i:C(w_{i-n+1}^i) > 0}",
                        "P_{GT}(w_i|w_{i-n+1}^{i-1})}",
                        "{1 - \\Sigma_{w_i:C(w_{i-n+1}^{i}) > 0}",
                        "P_{GT}(w_i|w_{i-n+2}^{i-1})}",
                        "\\end{split}",
                        "\\end{equation}$$",
                        "In the model implemented here, each ",
                        "\\(\\alpha_{w_{i-n+1}^{i-1}}\\) is precomputed and ",
                        "stored locally, which provides the method its ",
                        "computational efficiency."
                    )
                )
            )
        )
    }
    else if (smoothing_method == "Kneser-Ney") {
        renderUI(
            withMathJax(
                tags$h3("Kneser-Ney Smoothing"),
                tags$p(
                    paste0(
                        "Kneser-Ney is another interpolated model in the same ",
                        "vein as Jelinek-Mercer, but utilizing a discounting ",
                        "method known as absolute discounting as well as a ",
                        "novel way of calculating unigram counts."
                    )
                ),
                tags$p(
                    paste0(
                        "First, absolute discounting refers to an operation ",
                        "that is essentially the inverse of additive ",
                        "smoothing, where a constant number of counts are ",
                        "subtracted from the observed count rather than added ",
                        "to it.  The purpose of this is not to represent a ",
                        "Bayesian prior as in additive smoothing, but to free ",
                        "up some constant probability mass which Kneser-Ney ",
                        "redistributes to lower-order models.  This gives a ",
                        "bigram probability measure",
                        "$$P_{KN}(w_i|w_{i-1}) = ",
                        "\\frac{\\text{max}(C(w_{i-1}, w_i) - \\delta, 0)}",
                        "{\\Sigma_{w'}C(w_{i-1}, w')} + ",
                        "\\lambda_{w_{i-1}}P_{KN}(w_i)$$",
                        "Which can be extended upwards via recursion, as with ",
                        "the other models.  As mentioned, each ",
                        "\\(\\lambda_{w_{i-1}}\\) is proportional to the ",
                        "total count mass subtracted in the discounting step, ",
                        "such that",
                        "$$\\lambda_{w_{i-1}} = \\frac{\\delta}",
                        "{\\Sigma_{w'}C(w_{i-1},w')} ",
                        "|\\{w': C(w_{i-1}, w_i) > 0\\}|$$"
                    )
                ),
                tags$p(
                    paste0(
                        "Second, the Kneser-Ney method is not grounded at a ",
                        "simple Maximum Likelihood unigram disctribution, ",
                        "but rather implements something called a ",
                        "\"continuation\" count.  Instead of computing a ",
                        "raw count \\(C(w_i)\\) equal to the total number ",
                        "of occurrences of \\(w_i\\) across the corpus, ",
                        "the continuation count refers to the number of ",
                        "different *contexts* which it *continues* (i.e. how ",
                        "many bigrams it completes), and therefore heavily ",
                        "discounts unigrams which are in some way ",
                        "context-dependent.  Consider, for instance, the ",
                        "'Francisco' part of the proper name 'San ",
                        "Francisco'.  Since it only occurs following the ",
                        "unigram 'San', it receives a continuation count of ",
                        "1 regardless of how many times the bigram 'San ",
                        "Francisco' occurs within the corpus.  Once these ",
                        "continuation counts have been computed, Kneser-Ney ",
                        "defines a unique unigram probability measure ",
                        "$$P_{KN}(w_i) = \\frac{C_{cont}(w_i)}",
                        "{\\Sigma_{w'}C_{cont}(w')}$$"
                    )
                ),
                tags$p(
                    paste0(
                        "Kneser-Ney is widely considered to be one of, if not ",
                        "the most effective smoothing models, and has been ",
                        "proven to be so by most experiments thus far."
                    )
                )
            )
        )
    }
    else if (smoothing_method == "Stupid Backoff") {
        renderUI(
            withMathJax(
                tags$h3("Stupid Backoff Smoothing"),
                tags$p(
                    paste0(
                        "So-called \"Stupid\" Backoff is a smoothing model ",
                        "devised by Google engineers that approaches the ",
                        "accuracy of Kneser-Ney when exposed to especially ",
                        "large datasets.  The name refers to the simplicity ",
                        "of the algorithm itself, and the engineers who ",
                        "developed it originally did not think it would be a ",
                        "particularly effective technique.  Alas it was and ",
                        "the name stuck."
                    )
                ),
                tags$p(
                    paste0(
                        "The algorithm itself almost could not be simpler.  ",
                        "At its core, it's a Backoff method similar to Katz ",
                        "Backoff, but without any of the frills.  In fact, ",
                        "all it does at each backoff step is return a ",
                        "Maximum Likelihood estimate scaled by a constant ",
                        "amount \\((0 < \\alpha < 1)\\), which can be set in ",
                        "the sidebar to the left.  This results in the ",
                        "following probability measure",
                        "$$S_{SB}(w_i|w_{i-n+1}^{i-1}) = \\left\\{",
                        "\\begin{array}{11}",
                        "P_{MLE}(w_i|w_{i-n+1}^{i-1}) & \\quad ",
                        "\\text{if } C(w_{i-n+1}^i) > 0 \\\\",
                        "\\alpha S_{SB}(w_i|w_{i-n+2}^{i-1}) & \\quad ",
                        "\\text{otherwise}",
                        "\\end{array}",
                        "\\right.$$"
                    )
                ),
                tags$p(
                    paste0(
                        "Note, however, that since no effort is made to ",
                        "maintain a normalization condition, the values ",
                        "returned by the above expression technically are not ",
                        "real probabilities, simply relative scores, with the ",
                        "notation changed from \\(P\\) to \\(S\\) to reflect ",
                        "that shift.  This same simplicity allows it to be ",
                        "easily the fastest algorithm of the bunch presented ",
                        "here, but its accuracy comes primarily from corpus ",
                        "size and not the sophistication of the smoothing ",
                        "method itself."
                    )
                )
            )
        )
    }
    else {
        stop(sprintf("smoothing method not recognized: %s", smoothing_method))
    }
}


shinyServer(function(input, output) {
    
    smoother <- NULL
    triggers <- reactiveValues()
    triggers$predictions <- 0
    
    ###################
    #  Sidebar Panel  #
    ###################
    
    observeEvent(input$truncate_rows, {
        toggleState("max_rank", condition = input$truncate_rows)
        toggle("max_rank", condition = input$truncate_rows, anim = TRUE, 
               time = 0.3)
    })
    
    observeEvent(input$model, {
        toggleState("lambda", condition = (input$model == "Jelinek-Mercer"))
        toggle("lambda", condition = (input$model == "Jelinek-Mercer"),
               anim = TRUE, time = 0.3)
        
        toggleState("delta", condition = (input$model == "Kneser-Ney"))
        toggle("delta", condition = (input$model == "Kneser-Ney"),
               anim = TRUE, time = 0.3)
        
        toggleState("alpha", condition = (input$model == "Stupid Backoff"))
        toggle("alpha", condition = (input$model == "Stupid Backoff"),
               anim = TRUE, time = 0.3)
    })
    
    ################
    #  Main Panel  #
    ################
    
    calculate_predictions <- function() {
        model <- input$model
        hist <- input$history
        if (model == "Maximum Likelihood") {
            predictions <- smoother$maximum_likelihood(hist)
        } else if (model == "Laplace") {
            predictions <- smoother$laplace(hist)
        } else if (model == "Good-Turing") {
            predictions <- smoother$good_turing(hist)
        } else if (model == "Jelinek-Mercer") {
            predictions <- smoother$jelinek_mercer(hist, input$lambda)
        } else if (model == "Katz Backoff") {
            predictions <- smoother$katz_backoff(hist)
        } else if (model == "Kneser-Ney") {
            predictions <- smoother$kneser_ney(hist, input$delta)
        } else if (model == "Stupid Backoff") {
            predictions <- smoother$stupid_backoff(hist, input$alpha)
        } else {
            stop(sprintf("model not recognized: %s", model))
        }
        head(predictions, input$num_results)
    } 
    
    trigger_predictions <- debounce(reactive({
        list(input$model, 
             input$lambda, 
             input$delta, 
             input$alpha, 
             input$history,
             input$num_results,
             triggers$predictions)
    }), 100)
    
    observeEvent(trigger_predictions(), {
        prediction_table <- calculate_predictions()
        if (input$model == "Stupid Backoff") {
            g <- ggplot(prediction_table, 
                        aes(x = reorder(token, score), y = score))
        } else {
            g <- ggplot(prediction_table, 
                        aes(x = reorder(token, prob), y = prob))
        }
        prediction_plot <- g +
            geom_bar(stat = "identity") + 
            coord_flip() + 
            theme(axis.title = element_blank(),
                  axis.text = element_text(size = 12))
        
        prediction_cloud <- wordcloud2(prediction_table,
                                       minRotation = 0,
                                       maxRotation = 0)
        
        output$prediction_table <- renderTable({prediction_table})
        output$prediction_plot <- renderPlot({prediction_plot})
        output$prediction_cloud <- renderWordcloud2({prediction_cloud})
    })
    
    trigger_model_tuning <- debounce(reactive({
        list(input$max_n,
             input$min_threshold,
             input$truncate_rows,
             input$max_rank)
    }), 1000)
    
    observeEvent(trigger_model_tuning(), priority = 10, {
        rank <- ifelse(input$truncate_rows, input$max_rank, Inf)
        model_path <- file.path("models",
                                sprintf("thresh%s", input$min_threshold),
                                sprintf("thresh%s.max%s.Rdata", 
                                        input$min_threshold,
                                        rank))
        if (file.exists(model_path)) {
            smoother <<- NULL; gc(FALSE); load(file = model_path)
            smoother <<- p; rm(p); gc(FALSE)
        } else {
            stop(sprintf("model not found: %s", model_path))
        }
        
        smoother$max_n <- input$max_n
        output$mem_utilization <- renderText(humanReadable(mem_used()))
        triggers$predictions <- triggers$predictions + 1
    })
    
    observeEvent(input$model, {
        output$smoothing_description <- get_smoothing_description(input$model)
    })
    
    observeEvent(input$show_table, {
        showTab("output_format", "Table", select = TRUE)
    })
    
    observeEvent(input$show_plot, {
        showTab("output_format", "Plot", select = TRUE)
    })
    
    observeEvent(input$show_cloud, {
        showTab("output_format", "Wordcloud", select = TRUE)
    })

})
