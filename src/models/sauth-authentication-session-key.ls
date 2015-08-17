require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

schema = new Schema do
	app-id:     {type: Schema.Types.ObjectId, required: yes}
	key:        {type: String,                required: yes, unique: yes}
	is-invalid: {type: Boolean,               required: no,  default: no}

module.exports = db.model \SAuthAuthenticationSessionKey schema
