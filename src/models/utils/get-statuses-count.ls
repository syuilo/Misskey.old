require! {
	'../status': Status
}

exports = (user-id) -> 
	resove, reject <- new Promise!
	err, count <- Status.count {user-id}
	if err?
		then reject err
		else resolve count