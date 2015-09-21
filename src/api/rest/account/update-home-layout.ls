require! {
	'../../auth': authorize
	'../../../models/user-home-layout': UserHomeLayout
	'../../../models/utils/filter-user-for-response'
	'../../../utils/get-express-params'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[layout] = get-express-params req, <[ layout ]>

	(err, user-home-layout) <- UserHomeLayout.find-one {user-id: user.id}
	if user-home-layout?
		user-home-layout.layout = layout
		user-home-layout.save!
		res.api-render user.to-object!
	else
		new-layout = new UserHomeLayout {user-id: user.id, layout: layout}
		err, created-layout <- new-layout.save
		res.api-render user.to-object!
