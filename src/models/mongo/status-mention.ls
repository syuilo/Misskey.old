require! {
	mongoose
	'../../config': config
}

db = mongoose.connect config.mongo.uri, config.mongo.options

post-mention-schema = new mongoose.Schema do
	id: { type: Number, required: true }
	post-id: { type: Number, required: true }
	user-id: { type: Number, required: true }

exports = db.model \PostMention post-mention-schema
