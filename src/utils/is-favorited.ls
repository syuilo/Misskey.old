require! {
	'../models/status-favorite': StatusFavorite
}

exports = (status-id, user-id, callback) ->
	StatusFavorite.find-one { status-id, user-id } (, target-status-favorite) ->
		| target-status-favorite => callback true
		| _ => callbacl false
