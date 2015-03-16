require! {
	async
	'../../models/user-following': UserFollowing
	'../../models/post': Post
	'../utils/timeline': Timeline
}
post-gets =
	home: Post.getTimeline
	mention: Post.getMentions
module.exports = (req, res, content = 'home') ->
	async.series [
		(callback) -> Post.get-user-posts-count req.me.id, (count) -> callback null, count
		(callback) -> UserFollowing.get-followings-count req.me.id, (count) -> callback null, count
		(callback) -> UserFollowing.get-followers-count req.me.id, (count) -> callback null, count
		(callback) -> post-gets[content] req.me.id, 30, null, null, (posts) ->
			Timeline.generate-html posts, req, (timeline-html) -> callback null, timeline-html
	], (err, results) -> res.display req, res, 'home' do
		posts-count: results[0]
		followings-count: results[1]
		followers-count: results[2]
		timeline-html: results[3]
