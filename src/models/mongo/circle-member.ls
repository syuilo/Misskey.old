require! {
	mongoose
	'../../config': config
}

db = mongoose.connect config.mongo.uri, config.mongo.options

circle-member-schema = new mongoose.Schema do
	circle-id: { type: Number, required: true }	
	user-id: { type: Number, required: true }
	created-at: { type: Date, default: Date.now }
	title: { type: String }
	is-master: { type: Boolean, default: false }
	is-executive: { type: Boolean, default: false }
	can-select-join-request: { type: Boolean, default: false }
	can-exclude-member: { type: Boolean, default: false }
	can-create-thread: { type: Boolean, default: false }
	can-create-note: { type: Boolean, default: false }

module.exports = db.model 'CircleMember' circle-member-schema
