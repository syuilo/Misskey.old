

require! {
	'../status-favorite': StatusFavorite
}

# Number -> Number -> Promise Boolean
module.exports = (user-id, status-id) ->
	resolve, reject <- new Promise!
	
	err, favorite <- StatusFavorite
		.find {user-id} `$and` {status-id}
		.limit 1
		.exec
		
	if err?
		then reject err
		else resolve favorite?
