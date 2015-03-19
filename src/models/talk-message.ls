require! {
	mongoose
	'../../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

talk-message-schema = new mongoose.Schema do
	app-id: { type: Number }
	created-at: { type: Date, default: Date.now, required: yes }
	is-deleted: { type: Boolean, default: no }
	is-image-attached { type: Boolean, required: yes }
	is-readed: { type: Boolean, default: no }
	is-modified: { type: Boolean, default: no }
	otherparty-id: { type: Number, required: yes }
	text: { type: String }
	user-id: { type: Number, required: yes }

exports = db.model \TalkMessage talk-message-schema
