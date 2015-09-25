require! {
	moment
	'../../../../../models/user': User
	'../../../../../config'
}

module.exports = (req, res, options) ->
	user = options.user
	me = if req.login then req.me else null

	res.display req, res, \user-profile {
		bio: user.bio
		user
		page: \profile
	}
