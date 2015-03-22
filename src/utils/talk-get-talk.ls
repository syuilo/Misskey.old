import require \prelude-ls

require! {
	'../models/talk-message': TalkMessage
}

# a -> b -> [a, b]
$or = (x, y) --> {$or: [x, y]}

# a -> b -> [a, b]
$and = (x, y) --> {$and: [x, y]}

# Number -> Number -> Number -> Number -> Number -> Promise [Message]
exports = (me-id, otherparty-id, limit, since-id, max-id) ->
	(resolve, reject) <- new Promise!
	base-query =
		({user-id: me-id} `$and` {otherparty-id}) `$or` ({user-id: otherparty-id} `$and` {otherparty-id: me-id})
	
	query = | !any (?), [since-id, max-id] => base-query
		| since-id? => base-query `$and` {id: {$gt: since-id}}
		| max-id? => base-query `$and` {id: {$lt: max-id}}

	err, messages <- TalkMessage.find query .sort \-created-at .limit limit .exec
	if err?
		reject err
	else
		resolve messages
