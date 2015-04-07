require! {
	'../circle': Circle
}

# String -> Promise Boolean
module.exports = (screen-name) ->
	resolve, reject <- new Promise!
	
	err, exist <- Circle
		.find {screen-name}
		.limit 1
		.exec
		
	if err?
		then reject err
		else resolve exist?
