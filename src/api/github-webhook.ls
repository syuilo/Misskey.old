require! {
	'github-webhook-handler': github-webhook-handler
	'./internal/create-status'
	'../models/user': User
	'../config'
}

module.exports = (app) ->
	app.all '*' (req, res, next) ->
		handler = github-webhook-handler {path: '/github-webhook', secret: config.github-webhook-secret}

		handler req, res, (err) ->
			next!
			
		(err, noticer) <- User.find-one {screen-name: 'misskey_github'}

		handler.on \error (err) ->
			console.error 'Error:' err.message

		handler.on \push (event) ->
			create-status null noticer, "Pushされたようです。#{event.payload.ref}"
			console.log event.payload

		handler.on \issues (event) ->
			#create-status null noticer, ""
			console.log "Received an issue event for #{event.payload.repository.name} action=#{event.payload.action}: \##{event.payload.issue.number} #{event.payload.issue.title}"
