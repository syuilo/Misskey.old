require! {
	'../application': Application
	'../user': User
	'../bbs-post': BBSPost
	'../../config'
}

module.exports = (post, callback) ->
	post .= to-object!
	post.display-created-at = moment post.created-at .format 'YYYY年MM月DD日 HH時mm分ss秒'
	(, user) <- User.find-by-id post.user-id
	post.user = user
	callback post
