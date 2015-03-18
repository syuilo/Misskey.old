require! {
	mongoose
	'../../config': config
}

db = mongoose.connect config.mongo.uri, config.mongo.options

circle-join-request-schema = new mongoose.Schema do
	created-at: { type: Date, default: Date.now }
	user-id: { type: Number, required: true }

circle-member-schema = new mongoose.Schema do
	user-id: { type: Number, required: true }
	created-at: { type: Date, default: Date.now }
	title: { type: String }
	is-master: { type: Boolean, default: false }
	is-executive: { type: Boolean, default: false }
	can-select-join-request: { type: Boolean, default: false }
	can-exclude-member: { type: Boolean, default: false }
	can-create-thread: { type: Boolean, default: false }
	can-create-note: { type: Boolean, default: false }

circle-schema = new mongooes.Schema do
	created-at: { type: Date, default: Date.now }
	description: { type: String }
	join-requests: {[circle-join-request-schema]}
	members: {[circle-member-schema]}
	name: { type: String, required: true }
	screen-name: { type: String, required: true }
	user-id: { type: Number, required: true }

module.exports = db.model 'Circle' circle-schema
