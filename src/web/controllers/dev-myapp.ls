require! {
	async
	'../../models/application': Application
}
module.exports = (req, res) ->
	async.series [
		(callback: any) -> Application.find req.query.q, (app) -> callback null app
	], (err, results) -> res.display req, res, 'dev-myapp', app: results[0]
