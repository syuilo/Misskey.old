require! {
	'../../auth': authorize
	'../../internal/unpin-status'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	unpin-status do
		app, user
	.then do
		(user) ->
			res.api-render user.to-object!
		(err) ->
			res.api-error 400 err
