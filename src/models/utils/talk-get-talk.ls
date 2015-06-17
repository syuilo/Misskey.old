require! {
	'../../utils/is-null'
	'../talk-message': TalkMessage
}

# ID -> ID -> Number -> Number -> Number -> Promise [Message]
module.exports = (me-id, otherparty-id, limit, since-cursor, max-cursor) ->
	base-query = ({user-id: me-id} `$and` {otherparty-id}) `$or` ({user-id: otherparty-id} `$and` {otherparty-id: me-id})

	query = | all is-null, [since-cursor, max-cursor] => base-query
		| since-cursor? => base-query `$and` {cursor: {$gt: since-cursor}}
		| max-cursor?   => base-query `$and` {cursor: {$lt: max-cursor}}

	TalkMessage.find query .sort \-created-at .limit limit .exec!
