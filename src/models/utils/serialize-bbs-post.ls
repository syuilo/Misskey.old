require! {
	'../application': Application
	'../user': User
	'../bbs-post': BBSPost
	'../../config'
}

module.exports = (post, callback) ->
	post .= to-object!
	post.display-created-at = moment post.created-at .format 'YYYY年M月D日 H時m分s秒'
	(, user) <- User.find-by-id post.user-id
	post.user = user
	callback post
