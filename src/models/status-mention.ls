require! {
	mongoose
	'../config'
}

db = mongoose.create-connection config.mongo.uri, config.mongo.options

status-mention-schema = new mongoose.Schema do
	status-id: {type: Number, required: yes}
	user-id:   {type: Number, required: yes}

module.exports = db.model \StatusMention status-mention-schema
