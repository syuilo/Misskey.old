require! {
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
	
	function serialize-stream-object(messages)
		Promise.all (messages |> map (message) ->
			resolve, reject <- new Promise!
			Application.find-by-id message.app-id, (, app) ->
				message.app = app
				message.user = if message.user-id == me.id then me else otherparty
				message.otherparty = if message.user-id == me.id then otherparty else me
				resolve message)

	talk-get-talk me.id, otherparty.id, 32messages, null, null .then (messages) ->
		user-following-check otherparty-id, me.id .then (following-me) ->
			messages |> each (message) ->
				if message.user-id == otherparty.id
					TalkMessage.update do
						{id: message.id}
						{$set: {+is-readed}}
						{-upsert, -multi}
						->
				
				serialize-stream-object messages .then (messages) ->
					res.display req, res, \user-talk {
						otherparty
						messages
						following-me
						no-header: req.query.noheader == \true
					}
