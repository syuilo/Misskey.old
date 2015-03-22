require! {
	'../models/status-mention': StatusMention
}

exports = (user-id, limit, since-id, max-id, callback) ->
	function query-callback(err, mentions)
		callback mentions
	query = switch
		| !since-id? and !max-id? => { user-id }
		| since-id? => { $and: [ user-id, status-id: { $gt: since-id } ] }
		| max-id? => { $and: [ user-id, status-id: { $lt: max-id } ] }
	StatusMention
		.find query
		.sort \-status-id # Desc
		.limit limit
		.exec query-callback
