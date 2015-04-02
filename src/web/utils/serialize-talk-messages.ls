require! {
	'./serialize-talk-message'
	'../../config'
}

# [TalkMessage] -> User -> User -> Promise [TalkMessage]
module.exports = (messages, me, otherparty) ->
	if empty messages
		new Promise (resolve) -> resolve null
	else
		Promise.all (messages |> map (message) -> serialize-talk-message message, me, otherparty)