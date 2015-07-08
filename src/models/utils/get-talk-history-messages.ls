require! {
	'../talk-message': TalkMessage
	'../talk-history': TalkHistory
}

# ID -> Promise [TalkMessage]
module.exports = (user-id) ->
	resolve, reject <- new Promise!

	(, histories) <- TalkHistory
		.find {user-id}
		.sort \-createdAt
		.exec

	promises = histories |> map (history) -> new Promise (resolve-history, reject-history) ->
		TalkMessage.find-by-id history.message-id, (, message) -> resolve-history message
	Promise.all promises .then resolve
