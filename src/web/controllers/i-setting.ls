require! {
	async
	'../../models/user': User
	'../../models/webtheme': Webtheme
}
module.exports = (req, res) -> Webtheme.find {} (, themes) ->
	async.map themes,
		(theme, next) -> User.find-by-id theme.user-id, (, user) ->
			theme.user = user
			next null theme
		(, results) -> res.display req, res, 'i-setting' do
			me: req.me
			webthemes: results
