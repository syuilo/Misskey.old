import require \prelude-ls

# Request -> String -> String
get-express-param = (req, name) --> req[{GET: \query, POST: \body}[req.method] ? \query][name] ? null

# Request -> [String] -> [String]
exports = (req, names) --> names |> map get-express-param req
