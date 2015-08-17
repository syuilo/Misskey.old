require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

schema = new Schema do
	app-id:      {type: Schema.Types.ObjectId, required: yes}
	user-id:     {type: Schema.Types.ObjectId, required: yes}
	session-key: {type: String,                required: yes}
	pin-code:    {type: String,                required: yes}

module.exports = db.model \SAuthPINCode schema
