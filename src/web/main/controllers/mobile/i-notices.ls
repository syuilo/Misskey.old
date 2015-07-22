require! {
	jade
	'../../../../models/notice': Notice
	'../../../../models/utils/notice-get-timeline'
	'../../utils/generate-mobile-notice-timeline-html'
}

module.exports = (req, res) ->
	notice-get-timeline do
		req.me.id
		30notices
	.then (notices) ->
		if notices?
			generate-mobile-notice-timeline-html req.me, notices .then (html) ->
				res.display req, res, 'mobile/i-notices' do
					timeline-html: html
		else
			res.display req, res, 'mobile/i-notices' do
				timeline-html: null
			