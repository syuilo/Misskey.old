require! {
	'../../../models/utils/status-check-favorited'
	'../../../models/utils/status-check-reposted'
	'../../../models/utils/serialize-status'
	'../../../config'
}

module.exports = (status, me, callback) ->
	serialize-status status, (serialized-status) ->
		if me?
			serialized-status.is-favorited <- status-check-favorited me.id, serialized-status.id .then
			serialized-status.is-reposted <- status-check-reposted me.id, serialized-status.id .then
			#serialized-status.is-favorited = no
			#serialized-status.is-reposted = no
			callback serialized-status
		else
			serialized-status.is-favorited = null
			serialized-status.is-reposted = null
			callback serialized-status
