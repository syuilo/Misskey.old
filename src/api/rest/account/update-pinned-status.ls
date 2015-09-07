require! {
	'../../auth': authorize
	'../../internal/pin-status'
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[status-id] = get-express-params req, <[ status-id ]>

	pin-status do
		app, user, status-id
	.then do
		(status) ->
			res.api-render status.to-object!
		(err) ->
			res.api-error 400 err
