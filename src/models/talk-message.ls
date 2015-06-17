require! {
	mongoose
	'mongoose-auto-increment'
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

mongoose-auto-increment.initialize db

talk-message-schema = new Schema do
	app-id:            {type: Schema.Types.ObjectId, required: yes}
	created-at:        {type: Date,                  required: yes, default: Date.now}
	cursor:            {type: Number}
	is-deleted:        {type: Boolean,               default:  no}
	is-image-attached: {type: Boolean,               required: yes, default: no}
	is-readed:         {type: Boolean,               default:  no}
	is-edited:         {type: Boolean,               default:  no}
	otherparty-id:     {type: Schema.Types.ObjectId, required: yes}
	text:              {type: String,                required: yes}
	user-id:           {type: Schema.Types.ObjectId, required: yes}

# Auto increment
talk-message-schema.plugin mongoose-auto-increment.plugin, {model: \TalkMessage, field: \cursor}

module.exports = db.model \TalkMessage talk-message-schema
