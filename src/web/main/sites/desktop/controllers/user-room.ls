require! {
	'../../../../../models/user': User
	'../../../../../models/user-room': UserRoom
	'../../../../../config'
}

module.exports = (req, res, options) ->
	user = options.user
	me = if req.login then req.me else null
	
	err, room <- UserRoom.find-one {user-id: user.id}

	if room?
		res.display req, res, \user-room {
			items: room.items
			user
		}
	else
		res.display req, res, \user-room {
			user
		}