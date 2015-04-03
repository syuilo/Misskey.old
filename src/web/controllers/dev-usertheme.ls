require! {
	async
	'../../utils/get-express-params'
	'../../models/webtheme': webtheme
}
module.exports = (req, res) ->
	async.series [
		(callback) -> 
			[p] = get-express-params req, <[ p ]>
			webtheme.find q, (themes) -> callback null themes
	], (err, results) -> res.display req, res, 'dev-usertheme', theme: results.0
