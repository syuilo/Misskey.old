require! {
	'./create-bbs-post'
	'../../models/user': User
	'../../models/bbs-thread': BBSThread
	'../../models/bbs-post': BBSPost
	'../../models/bbs-thread-watch': BBSThreadWatch
}

module.exports = (app, user, title, text = null) ->
	resolve, reject <- new Promise!
	
	function throw-error(code, message)
		reject {code, message}
		
	title .= trim!
	if text? then text .= trim!
	
	switch
	| null-or-empty title => throw-error \empty-title 'Empty title.'
	| _ =>
		thread = new BBSThread!
			..title = title
			..user-id = user.id

		(, created-thread) <- thread.save
		
		watch = new BBSThreadWatch!
			..thread-id = created-thread.id
			..user-id = user.id
			
		(, created-watch) <- watch.save
		
		if text?
			create-bbs-post app, user, created-thread.id, text .then do
				(post) ->
					resolve created-thread
				(err) ->
					throw-error "create-post-#{err.code}" err.message
		else
			resolve created-thread
