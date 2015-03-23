require! {
	'../status': Status
}

exports = (user-id, callback) -> Status.count { user-id }, (, count) -> callback count