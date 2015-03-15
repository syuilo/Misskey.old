require! {
	mongoose
	'../../config': config
}

db = mongoose.connect config.mongo.uri, config.mongo.options

circle-schema = new mongooes.Schema do
	created-at: { type: String }
	description: { type: String }
	name: { type: String }
	screen-name: { type: String }
	user-id: { type: Number }

module.exports = db.model 'Circle' circle-schema
