require! {
	async
	'../../models/application': Application
	'../../models/webtheme': WebTheme
}
exports = (req, res) ->
	async.series [
		(callback) -> Application.find-by-user-id req.me.id, (apps) -> callback null apps
		(callback) -> WebTheme.find-by-user-id req.me.id, (themes) -> callback null themes
	], (err, results) ->
		res.display req, res, 'dev' do
			apps: results.0
			themes: results.1
