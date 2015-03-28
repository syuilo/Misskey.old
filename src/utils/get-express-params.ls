# Request -> String -> String
get-express-param = (req, name) --> req[{GET: \query, POST: \body}[req.method] ? \query][name] ? ''

# Request -> [String] -> [String]
module.exports = (req, names) --> names |> map get-express-param req
