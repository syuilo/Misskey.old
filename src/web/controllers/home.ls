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
		(next) -> Post.get-user-posts-count req.me.id, (count) -> next null, count
		(next) -> UserFollowing.get-followings-count req.me.id, (count) -> next null, count
		(next) -> UserFollowing.get-followers-count req.me.id, (count) -> next null, count
		(next) -> post-gets[content] req.me.id, 30, null, null, (posts) ->
			Timeline.generate-html posts, req, (timeline-html) -> next null, timeline-html
	], (err, results) -> res.display req, res, 'home' do
		posts-count: results[0]
		followings-count: results[1]
		followers-count: results[2]
		timeline-html: results[3]
