require! {
	'../../../api/internal/get-talk-timeline'
	'../../../models/application': Application
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
	'../../../models/talk-message': TalkMessage
	'../../../models/utils/user-following-check'
	'../utils/serialize-talk-messages'
	'../utils/generate-talk-messages-html'
}

module.exports = (req, res, view) ->
	me = req.me.to-object!
	otherparty = req.root-user.to-object!
	
	get-talk-timeline null, me, otherparty.id, 32messages, null, null .then (messages) ->
		messages .= reverse!
		
		user-following-check otherparty.id, me.id .then (following-me) ->
			serialize-talk-messages messages, me, otherparty .then (messages) ->
				generate-talk-messages-html messages, me .then (message-htmls) ->
					view-name = switch view
						| \normal => \user-talk
						| \widget => \widget-user-talk
					res.display req, res, view-name, {
						otherparty
						messages: message-htmls
						following-me
					}
