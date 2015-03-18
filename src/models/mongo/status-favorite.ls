require! {
	mongoose
	'../../config': config
}

db = mongoose.connect config.mongo.uri, config.mongo.options

status-favorite-schema = new mongoose.Schema do
	created-at: { type: Date, default: Date.now }
	status-id: { type: Number, required: true }
	user-id: { type: Number, required: true }	

module.exports = db.model 'StatusFavorite' status-favorite-schema
