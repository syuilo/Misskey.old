require! {
	async
	'../models/application': Application
	'../models/user': User
	'../models/user-following': UserFollowing
	'../models/talk-message': TalkMessage
	''
}

exports = (req, res) ->
	TalkMessage
		.find do
			$or: [
				{$and: [
					{ user-id: req.me.id }
					{ otherparty-id: req.root-user.id }
				]}
				{$and: [
					{ user-id: req.root-user.id }
					{ otherparty-id: req.me.id }
				]}
			]
		.sort \-created-at
		.limit 32
		.exec (, messages) ->
			