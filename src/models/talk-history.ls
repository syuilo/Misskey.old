require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

schema = new Schema do
	updated-at:    {type: Date,                  required: yes, default: Date.now}
	message-id:    {type: Schema.Types.ObjectId, required: yes}
	user-id:       {type: Schema.Types.ObjectId, required: yes}
	otherparty-id: {type: Schema.Types.ObjectId, required: yes}

module.exports = db.model \TalkHistory schema
