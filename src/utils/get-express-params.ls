import require \prelude-ls

# Request -> String -> Maybe String
get-express-param = (req, name) --> req[{GET: \query, POST: \body}[req.method] ? \query][name] ? null

# Request -> [String] -> [Maybe String]
exports = (req, names) --> names |> map get-express-param req
