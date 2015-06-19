require! {
	jade
	'../../auth': authorize
	'../../../utils/get-express-params'
	'../../../models/notice': Notice
	'../../../models/utils/notice-get-timeline'
	'../../../web/utils/generate-notice-timeline-item-html'
	'../../../config'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[since-cursor, max-cursor] = get-express-params req, <[ since-cursor, max-cursor ]>
	notice-get-timeline do
		user.id
		10notices
		if !empty since-cursor then Number since-cursor else null
		if !empty max-cursor then Number max-cursor else null
	.then (notices) ->
		if notices?
			promises = notices |> map (notice) ->
				generate-notice-timeline-item-html user, notice
			Promise.all promises .then (notice-htmls) ->
				res.api-render notice-htmls.join ''
		else
			res.api-render null