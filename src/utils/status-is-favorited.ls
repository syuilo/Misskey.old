require! {
	'../models/status-favorite': StatusFavorite
}

exports = (status-id, user-id) -> StatusFavorite.find { status-id, user-id } .limit 1 .count! > 0
