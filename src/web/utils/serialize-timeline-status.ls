require! {
	'../../models/utils/status-check-favorited'
	'../../models/utils/status-check-reposted'
	'../../models/utils/serialize-status'
	'../../config'
}

module.exports = (status, me, callback) ->
	serialize-status status, (serialized-status) ->
		serialized-status.is-favorited <- status-check-favorited me.id, serialized-status.id .then
		serialized-status.is-reposted <- status-check-reposted me.id, serialized-status.id .then
		callback serialized-status