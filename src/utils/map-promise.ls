# (a -> b) -> Promise a -> Promise b
module.exports = (f, promise) --> promise.then (x) -> new Promise (resolve,) -> resolve f x
