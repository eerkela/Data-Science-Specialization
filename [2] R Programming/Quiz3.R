## Eric Erkela
## Coursera Data Science Specialization
## Course 2: R Programming
## Week 3 Quiz

library(datasets)

###
data(iris)

#1
tapply(iris$Sepal.Length, iris$Species, mean)

#2
apply(iris[, 1:4], 2, mean)

###
data(mtcars)

#3
sapply(split(mtcars$mpg, mtcars$cyl), mean)
tapply(mtcars$mpg, mtcars$cyl, mean)
with(mtcars, tapply(mpg, cyl, mean))

#4
x <- tapply(mtcars$hp, mtcars$cyl, mean)
abs(x[["4"]] - x[["8"]])

#5
#debug(ls)
#ls