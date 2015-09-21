require! {
	'../../auth': authorize
	'../../../models/user-home-layout': UserHomeLayout
	'../../../models/utils/filter-user-for-response'
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[layout] = get-express-params req, <[ layout ]>

	console.log req.body
	console.log req.body.layout
	console.log layout

	save-layout = {
		left: []
		center: []
		right: []
	}

	if layout.left?
		layout.left |> each (widget) ->
			save-layout.left.concat widget
	if layout.center?
		layout.center |> each (widget) ->
			save-layout.center.concat widget
	if layout.right?
		layout.right |> each (widget) ->
			save-layout.right.concat widget

	console.log save-layout

	(err, user-home-layout) <- UserHomeLayout.find-one {user-id: user.id}
	if user-home-layout?
		user-home-layout.layout = save-layout
		user-home-layout.save!
		res.api-render user.to-object!
	else
		new-layout = new UserHomeLayout {user-id: user.id, layout: save-layout}
		err, created-layout <- new-layout.save
		res.api-render user.to-object!
