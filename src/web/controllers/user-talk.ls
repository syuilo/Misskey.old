require! {
	async
	'../../models/application': Application
	'../../models/user': User
	'../../models/user-following': UserFollowing
	'../../models/talk-message': TalkMessage
	'../../models/utils/talk-get-talk'
	'../../models/utils/user-following-check'
}

module.exports = (req, res) ->
	me = req.me
	otherparty = req.root-user
	
	function serialize-stream-object(messages, callback)
		async.map do
			messages
			(message, next) ->
				Application.find-by-id message.app-id, (, app) ->
					message.app = app
					message.user = if message.user-id == me.id then me else otherparty
					message.otherparty = if message.user-id == me.id then otherparty else me
					next null message
			(, result) ->
				callback result

	talk-get-talk me.id, otherparty.id, 32messages, null, null, (messages) ->
		user-following-check otherparty-id, me.id .then (following-me) ->
			messages.for-each (message) ->
				if message.user-id == otherparty.id
					TalkMessage.update do
						{id: message.id}
						{$set: {is-readed: true}}
						{upsert: false, multi: false}
						(, ) ->
				
				serialize-stream-object messages, (messages) ->
					res.display req, res, \user-talk {
						otherparty
						messages
						following-me
						no-header: req.query.noheader == \true
					}