require! {
	'../../../models/notice': Notice
	'../../auth': authorize
}
module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		notice-id = req.body.notice_id
		if notice-id == null
			res.api-error 400 'notice_id parameter is required :('
		else
			Notice.find notice-id, (notice) ->
				if notice.user-id != user.id
					res.api-error 400 'Cannot delete The notification which not addressed to you'
				else
					notice.destroy -> res.api-render status: 'success'
