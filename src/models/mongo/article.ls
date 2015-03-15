require! {
	mongoose
	'../../config': config
}

db = mongoose.connect config.mongo.uri, config.mongo.options

status-schema = new mongoose.Schema do
	content: { type: String, required: true }
	created-at: { type: Date, default: Date.now, required: true }
	user-id: { type: Number, required: true }

module.exports = db.model 'Status' status-schema
