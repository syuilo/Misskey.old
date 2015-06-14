# (a -> b) -> Promise a -> Promise b
module.exports = (f, promise) --> promise.then (x) -> Promise.resolve f x
