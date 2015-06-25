require! {
	'../../models/user': User
	'../../models/bbs-thread': BBSThread
}

module.exports = (app, user, title) ->
	resolve, reject <- new Promise!
	switch
	| null-or-empty title => reject 'Empty title.'
	| _ =>
		thread = new BBSThread!
			..title = title
			..user-id = user.id

		thread.save (err, created-thread) ->
			if err then reject err
			resolve created-thread
