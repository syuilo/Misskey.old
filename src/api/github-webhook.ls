require! {
	'github-webhook-handler': github-webhook-handler
	'../config'
}

module.exports = (app) ->
	app.all '*' (req, res, next) ->
		handler = github-webhook-handler {path: '/github-webhook', secret: config.github-webhook-secret}

		handler req, res, (err) ->
			next!

		handler.on \error (err) ->
			console.error 'Error:' err.message

		handler.on \push (event) ->
			console.log "Received a push event for #{event.payload.repository.name} to #{event.payload.ref}"

		handler.on \issues (event) ->
			console.log "Received an issue event for #{event.payload.repository.name} action=#{event.payload.action}: \##{event.payload.issue.number} #{event.payload.issue.title}"
