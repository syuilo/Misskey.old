require! {
	'../../models/user': User
	'../../models/bbs-thread': BBSThread
	'../../models/bbs-thread-favorite': BBSThreadFavorite
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
			(, favorite) <- BBSThreadFavorite.find-one {thread-id: thread.id} `$and` {user-id: user.id}
			if favorite?
				favorite.remove ->
					thread.favorites-count--
					thread.save ->
						resolve null
			else
				throw-error \already-not-favorite 'Already not favorite.'
		else
			throw-error \thread-not-found 'Thread not found.'
