require! {
	'../../../../../models/user': User
	'../../../../../config'
}

module.exports = (req, res, options) ->
	user = options.user

	me = if req.login then req.me else null

	res.display req, res, \user-room {
		user
	}
