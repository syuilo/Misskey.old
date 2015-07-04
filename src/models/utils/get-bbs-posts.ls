require! {
	'../bbs-post': BBSPost
}

module.exports = (thread-id, limit) ->
	BBSPost
		.find {thread-id}
		.sort \-createdAt
		.limit limit
		.exec!
