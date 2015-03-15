require! {
	mongoose
	'../../config': config
}

db = mongoose.connect config.mongo.uri, config.mongo.options

talk-message-schema = new mongoose.Schema do
	app-id: { type: Number }
	created-at: { type: Date, default: Date.now, required: true }
	is-deleted: { type: Boolean, default: false }
	is-image-attached { type: Boolean, required: true }
	is-readed: { type: Boolean, default: false }
	is-modified: { type: Boolean, default: false }
	otherparty-id: { type: Number, required: true }
	text: { type: String }
	user-id: { type: Number, required: true }

module.exports = db.model 'TalkMessage' talk-message-schema
