# Request -> String -> String
get-express-param = (req, name) --> req.params[name] ? req.body[name] ? req.query[name] ? ''

# Request -> [String] -> [String]
module.exports = (req, names) --> names |> map get-express-param req
