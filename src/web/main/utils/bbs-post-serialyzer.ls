require! {
	'../../../models/utils/serialize-bbs-post'
	'../../../config'
}

module.exports = (post, callback) ->
	serialize-bbs-post post, (serialized-post) ->
		callback serialized-post
