require! {
	'../../auth': authorize
	'../../../utils/get-express-params'
	'../../../models/notice': Notice
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[notice-id] = get-express-params req, <[ notice-id ]>
	switch
	| empty notice-id => res.api-error 400 'notice-id is required'
	| _ => Notice.find-by-id notice-id, (err, notice) ->
		| not notice? => res.api-error 404 'Notice not found'
		| notice.user-id != user.id => res.api-error 403 'Cannot show The notification which not addressed to you'
		| _ =>
			res.api-render notice.to-object!
