require! {
	'../status': Status
}

module.exports = (user-id) -> 
	resolve, reject <- new Promise!
	err, count <- Status.count {user-id}
	if err?
		then reject err
		else resolve count