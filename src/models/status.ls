require! {
	moment
	mongoose
	'mongoose-auto-increment'
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

mongoose-auto-increment.initialize db

status-schema = new Schema do
	app-id:                {type: Schema.Types.ObjectId,   required: no}
	created-at:            {type: Date,                    required: yes, default: Date.now}
	cursor:                {type: Number}
	favorites-count:       {type: Number,                  default: 0}
	in-reply-to-status-id: {type: Schema.Types.ObjectId,   default: null}
	is-image-attached:     {type: Boolean,                 default: false}
	replies:               {type: [Schema.Types.ObjectId], default: []}
	reposts-count:         {type: Number,                  default: 0}
	repost-from-status-id: {type: Schema.Types.ObjectId,   default: null}
	tags:                  {type: [String]                 default: []}
	text:                  {type: String,                  default: null}
	user-id:               {type: Schema.Types.ObjectId,   required: yes}

if !status-schema.options.to-object then status-schema.options.to-object = {}
status-schema.options.to-object.transform = (doc, ret, options) ->
	ret.id = doc.id
	ret.created-at = moment doc.created-at .format 'YYYY/MM/DD HH:mm:ss Z'
	delete ret._id
	delete ret.__v
	ret

# Auto increment
status-schema.plugin mongoose-auto-increment.plugin, {model: \Status, field: \cursor}

module.exports = db.model \Status status-schema
