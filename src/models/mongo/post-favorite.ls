require! {
	mongoose
	'../../config': config
}

db = mongoose.connect config.mongo.uri, config.mongo.options

post-favorite-schema = new mongoose.Schema do
	created-at: { type: Date, default: Date.now }
	post-id: { type: Number, required: true }
	user-id: { type: Number, required: true }	

module.exports = db.model 'PostFavorite' post-favorite-schema
