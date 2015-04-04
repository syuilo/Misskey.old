require! {
	'../../models/utils/status-check-favorited'
	'../../models/utils/status-check-reposted'
	'../../models/utils/serialize-status'
	'../../config'
}

module.exports = (status, me, callback, callsource = '未設定') ->
	serialize-status status, (serialized-status) ->
		serialized-status.is-favorited <- status-check-favorited me.id, serialized-status.id .then
		serialized-status.is-reposted <- status-check-reposted me.id, serialized-status.id .then
		#serialized-status.is-favorited = no
		#serialized-status.is-reposted = no
		callback serialized-status
	, callsource