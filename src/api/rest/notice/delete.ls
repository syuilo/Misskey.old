	require! {
	'../../auth': authorize
	'../../../models/notice': Notice
}
exports = (req, res) -> authorize res, res, (user, app) ->
	| !(notice-id = req.body.notice_id)? => res.api-error 400 'notice_id parameter is required :('
	| _ => Notice.find-by-id notice-id, (, notice) ->
		| notice.user-id != user.id => res.api-error 403 'Cannot delete The notification which not addressed to you'
		| _ => notice.destroy -> res.api-render status: \success
