require! {
	'../status': Status
}

# ID -> Number -> Number -> Number -> Promise [Status]
module.exports = (user-id, limit, since-cursor, max-cursor) -> new Promise (resolve, reject) ->
	query = | !since-cursor? and !max-cursor? => {user-id: user-id}
		| since-cursor? => (user-id: user-id) `$and` (cursor: {$gt: since-cursor})
		| max-cursor?   => (user-id: user-id) `$and` (cursor: {$lt: max-cursor})
	sort = | !since-cursor? and !max-cursor? => \-createdAt
		| since-cursor? => \createdAt
		| max-cursor?   => \-createdAt
	console.log since-cursor
	Status
		.find query
		.sort sort
		.limit limit
		.exec (, statuses) -> resolve statuses
