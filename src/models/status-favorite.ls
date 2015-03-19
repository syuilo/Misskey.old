require! {
	mongoose
	'../../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

status-favorite-schema = new mongoose.Schema do
	created-at: { type: Date, default: Date.now }
	status-id: { type: Number, required: yes }
	user-id: { type: Number, required: yes }

exports = db.model \StatusFavorite status-favorite-schema
