require! {
	'../../auth': authorize
	'../../../utils/get-express-params'
	'../../../models/notice': Notice
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	[notice-id] = get-express-params req, <[ notice-id ]>
	switch
	| empty notice-id => res.api-error 400 'noticeId parameter is required :('
	| _ => Notice.find notice-id, (notice) ->
		| notice.user-id != user.id => res.api-error 403 'Cannot delete The notification which not addressed to you'
		| _ =>  notice.destroy -> res.api-render status: 'success'
