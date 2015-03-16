require! {
	mongoose
	'../../config': config
}

db = mongoose.connect config.mongo.uri, config.mongo.options

post-schema = new mongoose.Schema do
	comments: {[
		{
			content: { type: String, required: true }
			created-at: { type: Date, required: true }
			user-id: { type: Number, required: true }
		}
	]}
	content: { type: String, required: true }
	created-at: { type: Date, default: Date.now, required: true }
	user-id: { type: Number, required: true }

module.exports = db.model 'Post' post-schema
