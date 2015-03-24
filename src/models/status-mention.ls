require! {
	mongoose
	'../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

status-mention-schema = new mongoose.Schema do
	status-id: { type: Number, required: true }
	user-id: { type: Number, required: true }

exports = db.model \StatusMention status-mention-schema
