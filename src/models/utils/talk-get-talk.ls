


require! {
	'../../utils/is-null'
	'../talk-message': TalkMessage
}

# Number -> Number -> Number -> Number -> Number -> Promise [Message]
module.exports = (me-id, otherparty-id, limit, since-id, max-id) ->
	resolve, reject <- new Promise!
	
	base-query = ({user-id: me-id} `$and` {otherparty-id}) `$or` ({user-id: otherparty-id} `$and` {otherparty-id: me-id})
	
	query = | all is-null, [since-id, max-id] => base-query
		| since-id? => base-query `$and` {id: {$gt: since-id}}
		| max-id? => base-query `$and` {id: {$lt: max-id}}

	err, messages <- TalkMessage.find query .sort \-created-at .limit limit .exec
	
	if err?
		then reject err
		else resolve messages
