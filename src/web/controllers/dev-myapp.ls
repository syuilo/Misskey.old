require! {
	async
	'../../models/application': Application
	'../../utils/get-express-params'
}
module.exports = (req, res) ->
	async.series [
		(callback) -> 
			[p] = get-express-params req, <[ p ]>
			Application.find q, (app) -> callback null app
	], (err, results) -> res.display req, res, 'dev-myapp', app: results.0
