require! {
}

module.exports = (app, user, id) ->
	resolve, reject <- new Promise!
	
	function throw-error(code, message)
		reject {code, message}
	
	#if user.is-plus
	#	# kyoppie
	#else
	#	throw-error \access-denied 'Access denied.'