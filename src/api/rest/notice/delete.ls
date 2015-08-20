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
		| app? and (notice.app-id.to-string! != app.id.to-string!) => res.api-error 403 'Forbidden'
		| notice.user-id != user.id => res.api-error 403 'Cannot delete The notification which not addressed to you'
		| _ =>
			notice.remove ->
				res.api-render status: 'success'
