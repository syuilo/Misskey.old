require! {
	'../../../internal/create-bbs-post'
	'../../../auth': authorize
	'../../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[text] = get-express-params req, <[ text ]>

	create-bbs-post do
		app, user, text
	.then do
		(post) ->
			res.api-render post.to-object!
		(err) ->
			res.api-error 400 err