require! {
	'github-webhook-handler': github-webhook-handler
	'./internal/create-status'
	'../models/user': User
	'../config'
}

module.exports = (app) ->
	app.all '*' (req, res, next) ->
		handler = github-webhook-handler {path: '/github-webhook', secret: config.github-webhook-secret}
		
		(err, noticer) <- User.find-one {screen-name: 'misskey_github'}

		handler.on \error (err) ->
			console.error 'Error:' err.message

		handler.on \push (event) ->
			create-status do
				null noticer, "Pushされたようです。#{event.payload.ref}"
			.then do
				(status) ->
					
				(err) ->
					console.error err

		handler.on \issues (event) ->
			console.log \kyoppie
			issue = event.payload.issue
			text = switch (event.payload.action)
				| \unassigned => "担当が解除されました:「#{issue.title}」#{issue.url}"
				| \labeled => "ラベルが付与されました:「#{issue.title}」#{issue.url}"
				| \unlabeled => "ラベルが削除されました:「#{issue.title}」#{issue.url}"
				| \opened => "新しいIssueが開かれました:「#{issue.title}」#{issue.url}"
				| \closed => "Issueが閉じられました:「#{issue.title}」#{issue.url}"
				| \reopened => "Issueが再度開かれました:「#{issue.title}」#{issue.url}"
			create-status do
				null noticer, text
			.then do
				(status) ->
					
				(err) ->
					console.error err
		
		handler req, res, (err) ->
			next!
