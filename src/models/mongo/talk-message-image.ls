require! {
	mongoose
	'../../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

talk-message-image-schema = new mongoose.Schema do
	image: { type: Buffer, default: null }
	message-id: { type: Number, required: yes }

exports = db.model \TalkMessageImage talk-message-image-schema
