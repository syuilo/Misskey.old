require! {
	async
	'../../models/application': Application
	'../../models/user': User
	'../../models/status': Status
	'../../models/status-favorite': StatusFavorite
	'../../models/utils/status-check-favorited'
	'../../models/utils/status-check-reposted'
	'./timeline-serialize-more-talk': serialize-talk
	'./status-serialyzer'
	'../../config'
}

module.exports = (statuses, me, callback) ->
	async.map do
		statuses
		(status, next) ->
			status-serialyzer status, me, (serialized-status) ->
			next null, serialized-status
		(err, results) ->
			callback results