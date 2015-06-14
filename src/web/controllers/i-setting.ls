require! {
	'../../models/user': User
	'../../models/webtheme': Webtheme
}
module.exports = (req, res) -> Webtheme.find {} (, themes) ->
	Promise.all (themes |> map (theme) ->
		resolve, reject <- new Promise!
		User.find-by-id theme.user-id, (, user) ->
			theme.user = user
			resolve theme)
	.then (themes) -> res.display req, res, 'i-setting' do
		me: req.me
		webthemes: themes
