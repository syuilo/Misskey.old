require! {
	'../application': Application
	'../user': User
	'../bbs-post': BBSPost
	'../../config'
}

module.exports = (post, callback) ->
	post .= to-object!
	(, user) <- User.find-by-id post.user-id
	post.user = user
	callback post
