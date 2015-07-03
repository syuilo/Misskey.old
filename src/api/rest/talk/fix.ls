require! {
	'../../auth': authorize
	'../../internal/update-talk-message'
	'../../../models/talk-message': TalkMessage
	'../../../models/utils/filter-talk-message-for-response'
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[message-id, text] = get-express-params do
		req, <[ message-id text ]>
		
	update-talk-message do
		app, user, message-id, text
	.then do
		(message) ->
			obj <- filter-talk-message-for-response message
			res.api-render obj
		(err) ->
			res.api-error 400 err