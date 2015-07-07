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
			(, already-favorite) <- BBSThreadFavorite.find-one {thread-id: thread.id} `$and` {user-id: user.id}
			if already-favorite?
				throw-error \already-favorite 'Already favorite.'
			else
				favorite = new BBSThreadFavorite!
					..thread-id = thread.id
					..user-id = user.id
				(, created-favorite) <- favorite.save
				thread.favorites-count++
				thread.save ->
					resolve created-favorite
		else
			throw-error \thread-not-found 'Thread not found.'
