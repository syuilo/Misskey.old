require! {
	'../application': Application
	'../user': User
}
module.exports = (src-talk-msg, callback) ->
	talk-msg = {
		id: src-talk-msg.id
		created-at: src-talk-msg.created-at
		is-image-attached: src-talk-msg.is-image-attached
		is-readed: src-talk-msg.is-readed
		is-modified: src-talk-msg.is-modified
		otherparty-id: src-talk-msg.otherparty-id
		text: src-talk-msg.text
		user-id: src-talk-msg.user-id
	}
	Promise.all [
		new Promise (resolve, reject) -> Application.find-by-id src-talk-msg.app-id, (, application) ->
			| app? => next null app
			| _ => resolve null
		new Promise (resolve, reject) -> User.find-by-id src-talk-msg.otherparty-id, (, otherparty) ->
			resolve otherparty
		new Promise (resolve, reject) -> User.find-by-id src-talk-msg.user-id, (, user) ->
			resolve user
	] .then ([talk-msg.application, talk-msg.otherparty, talk-msg.user])　-> callback talk-msg
