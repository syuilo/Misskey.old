require! {
	'../../../models/talk-message': TalkMessage
	'../../auth': authorize
}
exports = (req, res) -> authorize req, res, (user, app) ->
	msg-id = req.body.message_id
	switch
	| !msg-id? => res.api-error 400 'message_id parameter is required :('
	| _ => TalkMessage.find msg-id, (msg) ->
		| !msg? => res.api-error 400 'Message not found.'
		| msg.otherparty-id != user.id => res.api-error 400 'Send Message opponent can only be to read.'
		| _ =>
			msg
				..is-read = true
				..update -> TalkMessage.build-response-object msg, res.api-render
