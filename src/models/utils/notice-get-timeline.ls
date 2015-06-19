require! {
	'../notice': Notice
}

# ID -> Number -> Number -> Number -> Promise [Status]
module.exports = (user-id, limit, since-cursor, max-cursor) -> new Promise (resolve, reject) ->
	query = | !since-cursor? and !max-cursor? => {user-id}
		| since-cursor? => ({user-id}) `$and` (cursor: {$gt: since-cursor})
		| max-cursor?   => ({user-id}) `$and` (cursor: {$lt: max-cursor})
	Notice
		.find query
		.sort \-createdAt # Desc
		.limit limit
		.exec (, notices) -> resolve notices
