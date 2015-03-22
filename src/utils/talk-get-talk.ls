require! {
	'../models/talk-message': TalkMessage
}

exports = (me-id, otherparty-id, limit, since-id, max-id, callback) ->
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
		| !since-id? and !max-id? => base-query
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
		.exec (, messages) ->
			callback messages