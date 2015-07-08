require! {
	'../../../models/application': Application
	'../../../models/user': User
	'../../../models/user-following': UserFollowing
	'../../../models/talk-message': TalkMessage
	'../../../models/utils/talk-get-talk'
	'../../../models/utils/user-following-check'
	'../utils/serialize-talk-messages'
	'../utils/generate-user-talk-message-stream-html'
}

module.exports = (req, res, view = \normal) ->
	me = req.me.to-object!
	otherparty = req.root-user.to-object!
	
	talk-get-talk me.id, otherparty.id, 32messages, null, null .then (messages) ->
		messages .= reverse!
		
		user-following-check otherparty.id, me.id .then (following-me) ->

			# 既読にする
			messages |> each (message) ->
				if message.user-id.to-string! == otherparty.id.to-string!
					message
						..is-readed = yes
						..save ->

			serialize-talk-messages messages, me, otherparty .then (messages) ->
				generate-user-talk-message-stream-html messages, me .then (message-htmls) ->
					view-name = switch view
						| \normal => \user-talk
						| \widget => \widget-user-talk
					res.display req, res, view-name, {
						otherparty
						messages: message-htmls
						following-me
					}
