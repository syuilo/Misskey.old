require! {
	'../../models/user': User
	'../../models/bbs-thread': BBSThread
	'../../models/bbs-thread-watch': BBSThreadWatch
}

module.exports = (app, user, thread-id) ->
	resolve, reject <- new Promise!
	
	function throw-error(code, message)
		reject {code, message}
		
	switch
	| null-or-empty thread-id => throw-error \empty-thread-id 'Empty thread-id.'
	| _ =>
		(, thread) <- BBSThread.find-by-id thread-id
		if thread?
			(, already-watch) <- BBSThreadWatch.find-one {thread-id: thread.id} `$and` {user-id: user.id}
			if already-watch?
				throw-error \already-watch 'Already watch.'
			else
				watch = new BBSThreadWatch!
					..thread-id = thread.id
					..user-id = user.id
				(, created-watch) <- watch.save
				thread.watchers-count++
				thread.save ->
					resolve created-watch
		else
			throw-error \thread-not-found 'Thread not found.'
