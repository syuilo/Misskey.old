require! {
	async
	'../../models/user': User
	'../../models/webtheme': WebTheme
}
module.exports = (req, res) -> WebTheme.get-themes (themes) ->
	async.map themes,
		(themes, next) -> User.find themes.user-id, (user) ->
			themes.user = user
			next null themes,
		(err, results) -> res.display req, res, 'i-setting' do
			me: req.me
			webthemes: results
