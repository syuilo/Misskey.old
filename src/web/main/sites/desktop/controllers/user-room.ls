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
			user
			room
		}
	else
		room = new UserRoom!
			..user-id = user.id
			..items =
				{
					individual-id: \a
					item-id: \bed
					position:
						x: 1.95
						y: 0
						z: -1.4
				}
				{
					individual-id: \b
					item-id: \carpet
					position:
						x: 0
						y: 0
						z: 0
				}
				{
					individual-id: \c
					item-id: \mat
					position:
						x: -2.2
						y: 0
						z: 0.4
				}
				{
					individual-id: \d
					item-id: \cardboard-box
					position:
							x: -2.2
							y: 0
							z: 1.9
				}
				{
					individual-id: \e
					item-id: \milk
					position: null
				}
				{
					individual-id: \f
					item-id: \facial-tissue
					position: null
				}
		
		room.save ->
			res.display req, res, \user-room {
				user
				room
			}