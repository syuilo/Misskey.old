require! {
	async
	'../../models/user': User
	'../../models/status': Status
	'../../models/status-favorite': StatusFavorite
	'../../models/utils/status-check-favorited'
	'../../models/utils/status-check-reposted'
	'../../models/utils/serialize-status'
	'../../config'
}

module.exports = (status, me, callback) ->
	serialize-status status, (serialized-status) ->
		serialized-status.is-favorited = no
		serialized-status.is-reposted = no
		callback serialized-status