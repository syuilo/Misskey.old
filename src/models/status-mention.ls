require! {
	mongoose
	'mongoose-auto-increment'
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

status-mention-schema = new Schema do
	created-at: {type: Date,                  required: yes, default: Date.now}
	cursor:     {type: Number}
	status-id:  {type: Schema.Types.ObjectId, required: yes}
	user-id:    {type: Schema.Types.ObjectId, required: yes}
	
# Auto increment
status-mention-schema.plugin mongoose-auto-increment.plugin, {model: \StatusMention, field: \cursor}

module.exports = db.model \StatusMention status-mention-schema
