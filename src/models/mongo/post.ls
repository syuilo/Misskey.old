require! {
	mongoose
	'../../config': config
}

db = mongoose.connect config.mongo.uri, config.mongo.options

comment-schema = new mongoose.Schema do
	content: { type: String, required: true }
	created-at: { type: Date, required: true }
	user-id: { type: Number, required: true }

post-schema = new mongoose.Schema do
	comments: [comment-schema]
	content: { type: String, required: true }
	created-at: { type: Date, default: Date.now, required: true }
	user-id: { type: Number, required: true }

module.exports = db.model 'Post' post-schema
