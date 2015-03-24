require! {
	mongoose
	'../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

notice-schema = new mongoose.Schema do
	app-id: { type: Number, required: yes }
	content: { type: String }
	created-at: { type: Date, default: Date.now }
	type: { type: String }
	user-id: { type: Number, required: yes }

exports = db.model \Notice notice-schema
