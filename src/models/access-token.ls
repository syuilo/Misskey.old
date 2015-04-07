require! {
	mongoose
	'../config'
}

db = mongoose.create-connection config.mongo.uri, config.mongo.options

access-token-schema = new mongoose.Schema do
	app-id:  {type: Number, required: yes}
	token:   {type: String, required: yes}
	user-id: {type: Number, required: yes}

module.exports = db.model \AccessToken access-token-schema
