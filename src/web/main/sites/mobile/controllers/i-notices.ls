require! {
	jade
	'../../../../../models/notice': Notice
	'../../../../../models/utils/notice-get-timeline'
	'../utils/generate-notice-timeline-html'
}

module.exports = (req, res) ->
	notice-get-timeline do
		req.me.id
		20notices
	.then (notices) ->
		if notices?
			generate-notice-timeline-html req.me, notices .then (html) ->
				res.display req, res, \i-notices do
					timeline-html: html
		else
			res.display req, res, \i-notices do
				timeline-html: null
			