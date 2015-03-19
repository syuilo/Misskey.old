require! {
	mongoose
	'../../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

circle-join-request-schema = new mongoose.Schema do
	created-at: { type: Date, default: Date.now }
	user-id: { type: Number, required: yes }

circle-member-schema = new mongoose.Schema do
	user-id: { type: Number, required: yes }
	created-at: { type: Date, default: Date.now }
	title: { type: String }
	is-master: { type: Boolean, default: no }
	is-executive: { type: Boolean, default: no }
	can-select-join-request: { type: Boolean, default: no }
	can-exclude-member: { type: Boolean, default: no }
	can-create-thread: { type: Boolean, default: no }
	can-create-note: { type: Boolean, default: no }

circle-schema = new mongooes.Schema do
	created-at: { type: Date, default: Date.now }
	description: { type: String }
	join-requests: {[circle-join-request-schema]}
	members: {[circle-member-schema]}
	name: { type: String, required: yes }
	screen-name: { type: String, required: yes }
	user-id: { type: Number, required: yes }

exports = db.model \Circle circle-schema
