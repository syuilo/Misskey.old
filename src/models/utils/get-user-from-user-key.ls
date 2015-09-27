require! {
	'../user': User
	'../user-key': UserKey
}

module.exports = (user-key) ->
	resolve, reject <- new Promise!
	
	switch
	| not user-key? => reject \undefined-user-key
	| empty user-key => reject \empty-user-key
	| _ =>
		(err, user-key-instance) <- UserKey.find-one {key: user-key}
		switch
		| err? => reject err
		| not user-key-instance? => \key-not-found
		| _ =>
			(err, user) <- User.find-by-id user-key-instance.user-id
			switch
			| err? => reject err
			| not user? => \user-not-found
			| _ =>
				resolve user
