require! {
	'../../../../../models/user': User
	'../../../../../models/user-key': UserKey
	'../../../../../models/application': App
}

module.exports = (req, res) ->
	# get user-keys
	(, user-keys) <- UserKey.find {user-id: req.me.id}

	# extract app-ids of user-keys
	app-ids = user-keys |> map (user-key) -> user-key.app-id

	# find apps
	(, apps) <- App.find {id: {$in: app-ids}}

	# serialize apps
	Promise.all (apps |> map (app) ->
		resolve, reject <- new Promise!
		app.to-object!
		# find author
		User.find-by-id app.user-id, (, user) ->
			app.user = user
			resolve app)
	.then (apples) ->

		# display
		res.display req, res, \i-apps do
			me: req.me
			apps: apples
