require! {
	mongoose
	'../../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

sauth-request-token-schema = new mongoose.Schema do
	app-id: { type: Number, required: true }
	in-invalid: { type: Boolean, default: false }
	token: { type: String }

exports = db.model \SAuthRequestToken sauth-request-token-schema
