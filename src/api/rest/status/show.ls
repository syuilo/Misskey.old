require! {
	'../../../models/status': Post
	'../../auth': authorize
}
module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		post-id = req.query\post-id
		if post-id == null
			res.api-error 400 'post_id parameter is required :('
		else
			Post.find post-id, (post) ->
				if post == null
					res.api-error 404 'Not found that post :('
				else
					Post.build-response-object post, (obj) -> res.api-render obj
