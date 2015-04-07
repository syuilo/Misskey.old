require! {
	'../../../models/notice': Notice
	'../../auth': authorize
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	notices <- Notice.find-by-user-id user.id
	Promise.all (notices |> map (notice) -> new Promise (resolve,) -> notice.destroy -> resolve!)
		.then -> res.api-render status: \success
