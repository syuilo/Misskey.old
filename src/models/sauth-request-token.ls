require! {
	mongoose
	'../config'
}

db = mongoose.create-connection config.mongo.uri, config.mongo.options

sauth-request-token-schema = new mongoose.Schema do
	app-id:     {type: Number, +required}
	in-invalid: {type: Boolean, -default}
	token:      {type: String}

module.exports = db.model \SAuthRequestToken sauth-request-token-schema
