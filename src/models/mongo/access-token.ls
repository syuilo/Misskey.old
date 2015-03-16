require! {
	mongoose
	'../../config': config
}

db = mongoose.connect config.mongo.uri, config.mongo.options

access-token-schema = new mongooes.Schema do
	app-id: { type: Number }
	token: { type: String }
	user-id: { type: Number }

module.exports = db.model 'AccessToken' access-token-schema
