require! {
	async
	'../../models/application': Application
	'../../models/webtheme': WebTheme
}
module.exports = (req, res) ->
	async.series [
		(callback) -> Application.find-by-id req.me.id, (, apps) -> callback null apps
		(callback) -> WebTheme.find-by-id req.me.id, (, themes) ->  callback null themes
	], (, [apps, themes]) ->
		res.display req, res, \dev, {apps, themes}
