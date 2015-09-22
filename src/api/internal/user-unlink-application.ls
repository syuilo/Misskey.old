require! {
	'../../models/user': User
	'../../models/user-key': UserKey
	'../../models/application': Application
	'./create-notice'
}

module.exports = (user, app-id) ->
	resolve, reject <- new Promise!

	function throw-error(code, message)
		reject {code, message}

	switch
	| empty app-id => throw-error \empty-app-id 'app-id is required.'
	| _ => Application.find-by-id app-id, (err, target-app) ->
		| not target-app? => throw-error \app-not-found 'Application not found.'
		| _ =>
			(err, user-keys) <- UserKey.find {user-id: user.id, app-id: target-app.id}
			user-keys |> each (user-key) -> user-key.remove!

			# Create notice
			create-notice null, user.id, \uninstall-app {
				app-id: target-app.id
			} .then ->

			resolve!
