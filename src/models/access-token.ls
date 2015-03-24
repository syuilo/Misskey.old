require! {
	mongoose
	'../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

access-token-schema = new mongooes.Schema do
	app-id: { type: Number, required: yes }
	token: { type: String, required: yes }
	user-id: { type: Number, required: yes }

exports = db.model \AccessToken access-token-schema
