require! {
	mongoose
	'../../config': config
}

db = mongoose.connect config.mongo.uri, config.mongo.options

access-token-schema = new mongooes.Schema do
	app-id: { type: Number, required: true }
	token: { type: String, required: true }
	user-id: { type: Number, required: true }

module.exports = db.model 'AccessToken' access-token-schema
