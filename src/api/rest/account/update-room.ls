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
		old-layout = user-room.items
		layout.for-each (item) ->
			old-item = (old-layout.filter (v, i) -> v.individual-id == item.individual-id).0
			old-item.position = item.position
			old-item.rotation = item.rotation

		console.log old-layout
		user-room.items = old-layout
		user-room.save (err) ->
			if err? then console.error err
			console.log user-room.items
			res.api-render user.to-object!
