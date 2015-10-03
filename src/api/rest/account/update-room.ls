require! {
	'../../auth': authorize
	'../../../models/user-room': UserRoom
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[layout] = get-express-params req, <[ layout ]>
	layout = JSON.parse layout

	(err, user-room) <- UserRoom.find-one {user-id: user.id}
	if user-room?
		new-layout = old-layout = user-room.items
		layout.for-each (item) ->
			old-layout.some (v, i) ->
				if v.individual-id == item.individual-id
					new-layout[i].position = item.position
					new-layout[i].rotation = item.rotation

		user-room.items = new-layout
		user-room.save ->
			res.api-render user.to-object!
