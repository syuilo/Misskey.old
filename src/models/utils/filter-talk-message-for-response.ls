require! {
	async
	'../application': Application
	'../user': User
}
module.exports = (src-talk-msg) ->
	talk-msg = {
		created-at: src-talk-msg.created-at
		is-image-attached: src-talk-msg.is-image-attached
		is-readed: src-talk-msg.is-readed
		is-modified: src-talk-msg.is-modified
		otherparty-id: src-talk-msg.otherparty-id
		text: src-talk-msg.text
		user-id: src-talk-msg.user-id
	}
	async.series do
		[
			(next) -> Application.find-by-id src-talk-msg.app-id, (, application) ->
				| app? => next null app
				| _ => next null null
			(next) -> User.find-by-id src-talk-msg.otherparty-id, (, otherparty) ->
				next null otherparty
			(next) -> User.find-by-id src-talk-msg.user-id, (, user) ->
				next null user
		]
		(, [talk-msg.application, talk-msg.otherparty, talk-msg.user])　-> callback talk-msg
