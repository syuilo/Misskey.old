import require './mongoose-query'

require! {
	'../status': Status
}

# Number -> Number -> Promise Boolean
exports = (user-id, status-id) ->
	resolve, reject <- new Promise!
	
	err, status <- Status
		.find {user-id} `$and` { repost-from-status-id: status-id }
		.limit 1
		.exec
		
	if err?
		then reject err
		else resolve status?
