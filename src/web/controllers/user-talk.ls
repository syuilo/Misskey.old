require! {
	'../../models/application': Application
	'../../models/user': User
	'../../models/user-following': UserFollowing
	'../../models/talk-message': TalkMessage
	'../../models/utils/talk-get-talk'
	'../../models/utils/user-following-check'
	'../utils/serialize-talk-messages'
	'../utils/generate-user-talk-message-stream-html'
}

module.exports = (req, res) ->
	me = req.me.to-object!
	otherparty = req.root-user.to-object!
	
	talk-get-talk me.id, otherparty.id, 32messages, null, null .then (messages) ->
		user-following-check otherparty.id, me.id .then (following-me) ->
			
			# 既読にする
			messages |> each (message) ->
				if message.user-id == otherparty.id
					TalkMessage.update do
						{id: message.id}
						{$set: {+is-readed}}
						{-upsert, -multi}
						->
			serialize-talk-messages messages, me, otherparty .then (messages) ->
				generate-user-talk-message-stream-html messages, me .then (message-htmls) ->
					res.display req, res, \user-talk {
						otherparty
						messages: message-htmls
						following-me
						no-header: noheader == \true
					}
