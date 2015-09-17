require! {
	'../../../../../models/user': User
}

module.exports = (req, res) ->
	res.display req, res, \i-settings-url
