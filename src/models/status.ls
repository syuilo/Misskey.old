require! {
	mongoose
	'../../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

status-schema = new mongoose.Schema do
	app-id: { type: Number, required: yes }
	created-at: { type: Date, default: Date.now, required: yes }
	favorites-count: { type: Number, default: 0 }
	in-reply-to-status-id: { type: Number, default: null }
	is-image-attached: { type: Boolean, default: false }
	replies: {[Number]}
	reposts-count: { type: Number, default: 0 }
	repost-from-status-id: { type: Number, default: null }
	text: { type: String, required: yes }
	user-id: { type: Number, required: yes }

exports = db.model \Status status-schema
