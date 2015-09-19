require! {
	'../../auth': authorize
	'../../internal/delete-talk-message'
	'../../../models/talk-message': TalkMessage
	'../../../models/utils/filter-talk-message-for-response'
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[message-id] = get-express-params do
		req, <[ message-id ]>

	delete-talk-message do
		app, user, message-id
	.then do
		->
			res.api-render \ok
		(err) ->
			res.api-error 400 err
