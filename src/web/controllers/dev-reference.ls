require! {
	jade
	fs
}
module.exports = (req, res) ->
	path = __dirname + '/../../reference/bad_request_error.jade'
	if req.query.q && req.query.q.indexOf '..' 0 == -1
		items = req.query.q.split '-'
		temp-path = __dirname + '/../../reference/apis/' + items.join '/' + '.jade'
		path = temp-path if fs.exists-sync temp-path
		res.display req, res, 'dev-reference', passed-html: (jade.compile-file path, {})!
