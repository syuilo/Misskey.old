require! {
	mongoose
	'../../config': config
}

db = mongoose.connect config.mongo.uri, config.mongo.options

circle-join-request-schema = new mongoose.Schema do
	created-at: { type: Date, default: Date.now }
	user-id: { type: Number, required: true }

circle-schema = new mongooes.Schema do
	created-at: { type: Date, default: Date.now }
	description: { type: String }
	join-requests: {[circle-join-request-schema]}
	name: { type: String, required: true }
	screen-name: { type: String, required: true }
	user-id: { type: Number, required: true }

module.exports = db.model 'Circle' circle-schema
