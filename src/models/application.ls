require! {
	mongoose
	'../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

application-schema = new mongoose.Schema do
	name: { type: String, required: yes }
	user-id: { type: Number, required: yes }
	created-at: { type: Date, default: Date.now }
	consumer-key: { type: String }
	callback-url: { type: String }
	description: { type: String, required: yes }
	developer-name: { type: String }
	developer-website: { type: String }
	is-suspended: { type: Boolean }

module.exports = db.model \Application application-schema
