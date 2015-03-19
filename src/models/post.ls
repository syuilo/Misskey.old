require! {
	mongoose
	'../../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

comment-schema = new mongoose.Schema do
	content: { type: String, required: yes }
	created-at: { type: Date, required: yes }
	user-id: { type: Number, required: yes }

post-schema = new mongoose.Schema do
	comments: [comment-schema]
	content: { type: String, required: yes }
	created-at: { type: Date, default: Date.now, required: yes }
	user-id: { type: Number, required: yes }

exports = db.model \Post post-schema
