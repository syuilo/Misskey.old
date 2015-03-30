require! {
	async
	'../../models/application': Application
	'../../models/user': User
	'../../models/status': Status
	'../../models/status-favorite': StatusFavorite
	'../../models/utils/status-check-favorited'
	'../../models/utils/status-check-reposted'
	'../../models/utils/serialize-status'
	'../../config'
}

module.exports = (statuses, me, callback) ->
	async.map do
		statuses
		(status, next) ->
			serialize-status status, (serialized-status) ->
				serialized-status.is-favorited = no
				serialized-status.is-reposted = no
				next null, serialized-status
		(err, results) ->
			callback results