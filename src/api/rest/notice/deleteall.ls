require! {
	async
	'../../../models/notice': Notice
	'../../auth': authorize
}
module.exports = (req, res) ->
	authorize req, res, (user, app) ->
		Notice.find-byuser-id user.id, (notices) ->
			async.map notices,
			(notice, next) -> notice.destroy -> next null null,
			(err, results) -> res.api-render status: 'success'
