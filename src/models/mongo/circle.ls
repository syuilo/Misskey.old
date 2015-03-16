require! {
	mongoose
	'../../config': config
}

db = mongoose.connect config.mongo.uri, config.mongo.options

circle-schema = new mongooes.Schema do
	created-at: { type: Date, default: Date.now }
	description: { type: String }
	name: { type: String, required: true }
	screen-name: { type: String, required: true }
	user-id: { type: Number, required: true }

module.exports = db.model 'Circle' circle-schema
