import require \prelude-ls

get-express-param = (req, name) --> req[{GET: \query, POST: \body}[req.method] ? \query][name] ? null

exports = (req, names) --> names |> map get-express-param req
