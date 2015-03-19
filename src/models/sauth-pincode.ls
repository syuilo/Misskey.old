require! {
	mongoose
	'../../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

sauth-pincode-schema = new mongoose.Schema do
	app-id: { type: Number, required: true }
	code: { type: String }
	user-id: { type: Number, required: true }

exports = db.model \SAuthPincode sauth-pincode-schema
