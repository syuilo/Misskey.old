require! {
	'../status': Status
	'../status-mention': StatusMention
	'../../utils/is-null'
}

# Number -> Number -> Number -> Number -> Promise [Status]
module.exports = (user-id, limit, since-cursor, max-cursor) -->
	resolve, reject <- new Promise!
	
	query = | all is-null, [since-cursor, max-cursor] => {user-id}
		| since-cursor? => {user-id} `$and` {cursor: {$gt: since-cursor}}
		| max-cursor?   => {user-id} `$and` {cursor: {$lt: max-cursor}}
	
	(, mentions) <- StatusMention
		.find query
		.sort \-createdAt
		.limit limit
		.exec
	
	promises = mentions |> map (mention) -> new Promise (resolve-mention, reject-mention) ->
		Status.find-by-id mention.status-id, (, status) -> resolve-mention status
	Promise.all promises .then resolve
