require! {
	async
	'../../models/webtheme': webtheme
}
module.exports = (req, res) ->
	async.series [
		(callback) -> webtheme.find req.query.q, (themes) -> callback null themes
	], (err, results) -> res.display req, res, 'dev-usertheme', theme: results.0
