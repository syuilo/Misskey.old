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
			text = switch (event.payload.ref)
				| \refs/heads/master => "安定チャンネルにPushされたようです。(master)\n**まもなくデプロイされる可能性があります。**"
				| \refs/heads/develop => "開発チャンネルにPushされたようです。(develop)"
				| _ => "Pushされたようです。#{event.payload.ref}"
			create-status null noticer, text .then!

		handler.on \issues (event) ->
			issue = event.payload.issue
			text = switch (event.payload.action)
				| \unassigned => "担当が解除されました:「#{issue.title}」#{issue.url}"
				| \labeled => "ラベルが付与されました:「#{issue.title}」#{issue.url}"
				| \unlabeled => "ラベルが削除されました:「#{issue.title}」#{issue.url}"
				| \opened => "新しいIssueが開かれました:「#{issue.title}」#{issue.url}"
				| \closed => "Issueが閉じられました:「#{issue.title}」#{issue.url}"
				| \reopened => "Issueが再度開かれました:「#{issue.title}」#{issue.url}"
			create-status null noticer, text .then!
		
		handler req, res, (err) ->
			next!
