require! {
	'../../../models/post': Post
	'../../../web/utils/timeline': Timeline
}
module.exports = (req, res) -> authorize req, res, (user, app) ->
	since-id = if req.query.since_id != null then req.query.since_id else null
	max-id = if req.query.max_id != null then req.query.max_id else null
	Post.get-timeline user.id, 30, since-id, max-id, (posts) ->
		Timeline.selialyze-timeline-object posts, user, (filted-posts) -> res.api-render filted-posts
