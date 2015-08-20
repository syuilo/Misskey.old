require! {
	'../../models/notice': Notice
	'../../utils/publish-redis-streaming'
	'../../config'
}

module.exports = (app, user-id, type, content = null) ->
	resolve, reject <- new Promise!
	
	function throw-error(code, message)
		reject {code, message}
	
	new Notice {
		app-id: if app? then app.id else null
		user-id
		type
		content
	}
	.save (err, created-notice) ->
		if err
			reject err
		else
			stream-obj = to-json do
				type: \notice
				value: created-notice.to-object!
			publish-redis-streaming "userStream:#user-id" stream-obj
			resolve created-notice