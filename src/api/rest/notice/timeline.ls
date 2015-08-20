require! {
	jade
	'../../auth': authorize
	'../../../utils/get-express-params'
	'../../../models/notice': Notice
	'../../../models/utils/notice-get-timeline'
	'../../../config'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[since-cursor, max-cursor, count] = get-express-params req, <[ since-cursor max-cursor count ]>
	if !empty count
		if count > 100
			count = 100
		if count < 1
			count = 1
	notice-get-timeline do
		user.id
		if !empty count then count else 20notices
		if !empty since-cursor then since-cursor else null
		if !empty max-cursor then max-cursor else null
	.then (notices) ->
		if notices?
			# 既読にする
			notices |> each (notice) ->
				notice
					..is-read = yes
					..save!
			serialized-notices = notices |> map (notice) ->
				notice.to-object!
			
			res.api-render serialized-notices
		else
			res.api-render null