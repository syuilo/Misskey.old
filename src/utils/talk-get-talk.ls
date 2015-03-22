import require \prelude-ls

require! {
	'../models/talk-message': TalkMessage
}

# Number -> Number -> Number -> Number -> Number -> Promise [Message]
exports = (me-id, otherparty-id, limit, since-id, max-id) ->
	(resolve, reject) <- new Promise!
	base-query =
		{$or: [
			{$and: [
				{ user-id: me-id }
				{ otherparty-id }
			]}
			{$and: [
				{ user-id: otherparty-id }
				{ otherparty-id: me-id }
			]}
		]}
	
	query = switch
		| !any (?), [since-id, max-id] => base-query
		| since-id? =>
			{$and: [
				base-query
				{ id: { $gt: since-id } }
			]}
		| max-id? =>
			{$and: [
				base-query
				{ id: { $lt: max-id } }
			]}
	
	TalkMessage
		.find query
		.sort \-created-at
		.limit limit
		.exec (, messages) -> resolve messages
