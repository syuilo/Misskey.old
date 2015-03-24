require! {
	mongoose
	mongoose-auto-increment
	'../../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

status-schema = new mongoose.Schema do
	app-id:                { type: Number,  required: yes }
	created-at:            { type: Date,    required: yes, default: Date.now }
	favorites-count:       { type: Number,  default: 0 }
	in-reply-to-status-id: { type: Number,  default: null }
	is-image-attached:     { type: Boolean, default: false }
	replies:               [Number]
	reposts-count:         { type: Number,  default: 0 }
	repost-from-status-id: { type: Number,  default: null }
	text:                  { type: String,  required: yes }
	user-id:               { type: Number,  required: yes }
	
# Virtual access _id property 
status-schema.virtual \id .get -> (@_id)

# Auto increment
status-schema.plugin mongoose-auto-increment.plugin, { model: \Status, field: '_id' }

exports = db.model \Status status-schema
