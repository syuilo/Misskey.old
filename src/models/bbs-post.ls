require! {
	moment
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

mongoose-auto-increment.initialize db

status-schema = new Schema do
	app-id:            {type: Schema.Types.ObjectId,   required: yes}
	created-at:        {type: Date,                    required: yes, default: Date.now}
	cursor:            {type: Number}
	is-image-attached: {type: Boolean,                 default: false}
	replies:           {type: [Schema.Types.ObjectId], default: []}
	text:              {type: String,                  required: yes}
	thread-cursor:     {type: Number,                  required: yes}
	thread-id:         {type: Schema.Types.ObjectId,   required: yes}
	user-id:           {type: Schema.Types.ObjectId,   required: yes}

if !schema.options.to-object then schema.options.to-object = {}
schema.options.to-object.transform = (doc, ret, options) ->
	ret.id = doc.id
	ret.created-at = moment doc.created-at .format 'YYYY/MM/DD HH:mm:ss Z'
	delete ret._id
	delete ret.__v
	ret

# Auto increment
schema.plugin mongoose-auto-increment.plugin, {model: \BBSPost, field: \cursor}

module.exports = db.model \BBSPost schema
