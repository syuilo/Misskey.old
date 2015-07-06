require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

talk-message-image-schema = new Schema do
	image:       {type: Buffer,                default: null}
	message-id:  {type: Schema.Types.ObjectId, required: yes}
	is-disabled: {type: Boolean,               required: no, default: no}

module.exports = db.model \TalkMessageImage talk-message-image-schema
