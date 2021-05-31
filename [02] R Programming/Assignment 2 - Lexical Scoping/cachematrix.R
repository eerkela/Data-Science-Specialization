## Eric Erkela
## Coursera Data Science Specialization
## Course 2: R Programming
## Programming Assignment 2: Lexical Scoping


## The following 2 functions describe (1) a cache matrix object with functions 
## to store and retrieve the matrix and its cached inverse, and (2) a function 
## to compute and assign said matrix's cached inverse.  These allow a user to
## lookup and store a matrix's inverse without repeatedly recalculating it,  
## which is usually a costly computation.


## in: an invertable matrix x
## out: a list of functions to get and set the matrix and its inverse
makeCacheMatrix <- function(x = matrix()) {
  inv <- NULL
  
  set <- function(y = matrix()) {
    x <<- y
    inv <<- NULL
  }
  get <- function() x
  setInverse <- function(inverse = matrix()) inv <<- inverse
  getInverse <- function() inv
  
  list(set = set, get = get, 
       setInverse = setInverse, 
       getInverse = getInverse)
}


## in: CacheMatrix x (see definition above)
## out: inverse of x.  If x's inverse has already been calculated, cacheSolve 
##      returns the cached inverse instead of recalculating.
cacheSolve <- function(x, ...) {
  inv <- x$getInverse()
  if (is.null(inv)) {
    matrix <- x$get()
    inv <- solve(matrix, ...)
    x$setInverse(inv)
  } else {
    message("Getting cached inverse...")
  }
  inv
}
