require! {
	async
	'../../models/application': Application
	'../../models/webtheme': WebTheme
}
module.exports = (req, res) ->
	async.series [
		(callback) -> Application.find-by-user-id req.me.id, callback null _
		(callback) -> WebTheme.find-by-user-id req.me.id, callback null _
	], (, [apps, themes]) ->
		res.display req, res, \dev, {apps, themes}
