#' Tools for making promises explicit
#'
#' An explicit promise is a forumula that has the expression on the RHS, and
#' the environment stored in the environment.
#'
#' @param x expression to make explicit, or to evaluate.
#' @export
#' @examples
#' # To do non-standard evaluation in a disciplined way, you first define
#' # the function that uses standard evaluation.  Using eval2 allows the
#' # input to be a formula or quoted call.
#' subset_q <- function(data, cond, env = parent.frame()) {
#'   r <- eval2(cond, data, env)
#'   r <- r & !is.na(r)
#'   data[r, , drop = FALSE]
#' }
#' subset_q(mtcars, quote(mpg > 31))
#' subset_q(mtcars, ~ mpg > 31)
#'
#' # Because formulas capture the environment in which they are created
#' # this works even when the formula is generated elsewhere
#' f <- function(x) ~ mpg > x
#' subset_q(mtcars, f(31))
#'
#' # Then the the non-standard evaluation version uses explicit to turn
#' # the promise into a formula
#' subset <- function(data, cond) {
#'   cond <- explicit(cond)
#'   subset_q(data, cond)
#' }
#' subset(mtcars, mpg > 31)
#' g <- function(x) subset(mtcars, mpg > x)
#' g(31)
explicit <- function(x) {
  explicitPromise(substitute(x), parent.frame())
}

#' @rdname explicit
#' @export
#' @param data Data in which to evaluate code
#' @param env Enclosing environment to use if data is a list or data frame.
eval2 <- function(x, data = NULL, env = parent.frame()) {
  if (is.formula(x)) {
    env <- environment(x)
    x <- x[[2]] # RHS of the formula
  }

  if (is.atomic(x)) return(x)
  stopifnot(is.call(x) || is.name(x))

  if (!is.null(data)) {
    eval(x, data, env)
  } else {
    eval(x, env)
  }
}

is.formula <- function(x) inherits(x, "formula")
