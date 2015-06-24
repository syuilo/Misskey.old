require! {
	'../../../utils/get-express-params'
	'../../../models/user': User
	'../../../models/bbs-thread': BBSThread
	'../../../config'
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[title] = get-express-params req, <[ title ]>

	switch
	| empty title => res.api-error 400 'title is required ><'
	| _ =>
		thread = new BBSThread!
			..title = title
			..user-id = user.id

		thread.save (err, created-thread) ->
			res.api-render created-thread.to-object!
