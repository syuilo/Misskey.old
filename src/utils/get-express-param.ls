exports = (req, name) --> req[{GET: \query, POST: \body}[req.method] ? \query][name] ? null
