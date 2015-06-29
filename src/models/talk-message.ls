require! {
	moment
	mongoose
	'mongoose-auto-increment'
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

mongoose-auto-increment.initialize db

schema = new Schema do
	app-id:            {type: Schema.Types.ObjectId, required: no}
	created-at:        {type: Date,                  required: yes, default: Date.now}
	cursor:            {type: Number}
	is-deleted:        {type: Boolean,               default:  no}
	is-image-attached: {type: Boolean,               required: yes, default: no}
	is-readed:         {type: Boolean,               default:  no}
	is-edited:         {type: Boolean,               default:  no}
	otherparty-id:     {type: Schema.Types.ObjectId, required: yes}
	text:              {type: String,                required: no, default: null}
	user-id:           {type: Schema.Types.ObjectId, required: yes}

if !schema.options.to-object then schema.options.to-object = {}
schema.options.to-object.transform = (doc, ret, options) ->
	ret.id = doc.id
	ret.created-at = moment doc.created-at .format 'YYYY/MM/DD HH:mm:ss Z'
	delete ret._id
	delete ret.__v
	ret

# Auto increment
schema.plugin mongoose-auto-increment.plugin, {model: \TalkMessage, field: \cursor}

module.exports = db.model \TalkMessage schema
