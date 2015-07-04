require! {
	'../../../internal/create-bbs-thread'
	'../../../auth': authorize
	'../../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[title, text] = get-express-params req, <[ title text ]>

	create-bbs-thread do
		app, user, title, text
	.then do
		(thread) ->
			res.api-render thread.to-object!
		(err) ->
			res.api-error 400 err