require! {
	'../status': Status
}

# ID -> Number -> Number -> Number -> Promise [Status]
module.exports = (user-id, limit, since-cursor, max-cursor) -> new Promise (resolve, reject) ->
	query = | !since-cursor? and !max-cursor? => {user-id: user-id}
		| since-cursor? => (user-id: user-id) `$and` (cursor: {$gt: since-cursor})
		| max-cursor?   => (user-id: user-id) `$and` (cursor: {$lt: max-cursor})
	Status
		.find query
		.sort \-createdAt # Desc
		.limit limit
		.exec (, statuses) -> resolve statuses
