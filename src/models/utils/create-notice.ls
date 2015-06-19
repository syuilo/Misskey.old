require! {
	'../notice': Notice
	'../../utils/publish-redis-streaming'
	'../../config'
}

# ID -> string -> Object -> Promise
module.exports = (user-id, type, content = null) -> new Promise (resolve, reject) ->
	new Notice {
		user-id
		type
		content
	}
	.save (err, created-notice) ->
		if err then reject err
		stream-obj = to-json do
			type: \notice
			value: created-notice.to-object!
		publish-redis-streaming "userStream:#user-id" stream-obj
		resolve created-notice