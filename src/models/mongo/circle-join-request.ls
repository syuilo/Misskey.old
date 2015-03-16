require! {
	mongoose
	'../../config': config
}

db = mongoose.connect config.mongo.uri, config.mongo.options

circle-join-request-schema = new mongoose.Schema do
	circle-id: { type: Number, required: true }
	created-at: { type: Date, default: Date.now, required: true }
	user-id: { type: Number, required: true }

module.exports = db.model 'CircleJoinRequest', circle-join-request-schema
