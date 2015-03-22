require! {
	'../models/status-favorite': StatusFavorite
}

exports = (status-id, user-id, callback) ->
	callback StatusFavorite.find-one { status-id, user-id }.count! > 0
