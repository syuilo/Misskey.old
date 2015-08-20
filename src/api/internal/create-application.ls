require! {
	'../../models/user': User
	'../../models/application': Application
	'./create-notice'
	'../../utils/publish-redis-streaming'
	'../../models/utils/exist-app-screen-id'
}

module.exports = (app, user, app-name, app-screen-id, app-description, app-callback-url = null) ->
	resolve, reject <- new Promise!

	function throw-error(code, message)
		reject {code, message}

	app-name .= trim!
	app-screen-id .= trim!
	app-screen-id-lower = app-screen-id.to-lower-case!
	app-description .= trim!
	if app-callback-url? then app-callback-url .= trim!
	
	switch
	| empty app-name => throw-error \empty-app-name 'app-name is required.'
	| empty app-screen-id => throw-error \empty-app-screen-id 'app-screen-id is required.'
	| app-screen-id == /^[0-9]+$/ || app-screen-id != /^[a-zA-Z0-9\-]{2,128}$/ => throw-error \invalid-app-screen-id 'app-screen-id invalid format'
	| empty app-description => throw-error \empty-app-description 'app-description is required.'
	| _ => exist-app-screen-id app-screen-id .then (exist) ->
		| exist => throw-error \screen-id-already-used 'This screen id is already used.'
		| _ =>
			# Generate APP KEY
			chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
			app-key = 'hmsk.'
			for i from 1 to 32 by 1
				app-key += chars[Math.floor (Math.random! * chars.length)]
			
			app = new Application!
				..user-id = user.id
				..name = app-name
				..screen-id = app-screen-id
				..screen-id-lower = app-screen-id-lower
				..description = app-description
				..app-key = app-key
				..callback-url = app-callback-url
				..permissions = [\all]
				..icon-image = 'contents/default-contents/app-icon.jpg'

			app.save (err, created-app) ->
				if err
					console.log err
					throw-error \unknown-error null
				else
					resolve created-app