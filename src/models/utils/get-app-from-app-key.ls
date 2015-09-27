require! {
	'../application': Application
}

module.exports = (app-key) ->
	resolve, reject <- new Promise!
	
	switch
	| not app-key? => reject \undefined-app-key
	| empty app-key => reject \empty-app-key
	| _ =>
		(err, app) <- Application.find-one {app-key}
		switch
		| err? => reject err
		| not app? => \not-found
		| _ =>
			resolve app
