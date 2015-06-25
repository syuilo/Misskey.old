require! {
	'../../../internal/create-bbs-thread'
	'../../../auth': authorize
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[title] = get-express-params req, <[ title ]>

	create-bbs-thread do
		app, user, title
	.then do
		(thread) ->
			res.api-render thread.to-object!
		(err) ->
			res.api-error 400 err