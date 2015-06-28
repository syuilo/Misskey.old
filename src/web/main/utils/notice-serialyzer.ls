require! {
	'../../../models/notice': Notice
	'../../../models/user': User
	'../../../models/status': Status
	'../../../config'
}

module.exports = (notice) -> new Promise (resolve, reject) ->
	notice .= to-object!
	switch notice.type
	| \self-notice => resolve notice
	| \follow =>
		err, user <- User.find-by-id notice.content.user-id
		notice.content.user = user.to-object!
		resolve notice
	| \status-repost =>
		err, user <- User.find-by-id notice.content.user-id
		err, repost-status <- Status.find-by-id notice.content.repost-id
		err, status <- Status.find-by-id notice.content.status-id
		notice.content.user = user.to-object!
		notice.content.repost-status = repost-status.to-object!
		notice.content.status = status.to-object!
		resolve notice
	| \status-favorite =>
		err, user <- User.find-by-id notice.content.user-id
		err, status <- Status.find-by-id notice.content.status-id
		notice.content.user = user.to-object!
		notice.content.status = status.to-object!
		resolve notice
	| _ =>
		reject "Unknown notice type '#notice.type'"