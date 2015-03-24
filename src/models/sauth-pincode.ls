require! {
	mongoose
	'../config'
}

db = mongoose.create-connection config.mongo.uri, config.mongo.options

sauth-pincode-schema = new mongoose.Schema do
	app-id: { type: Number, required: true }
	code: { type: String }
	user-id: { type: Number, required: true }

module.exports = db.model \SAuthPincode sauth-pincode-schema
