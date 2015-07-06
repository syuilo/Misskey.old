require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

status-image-schema = new Schema do
	image:        {type: Buffer}
	status-id:   {type: Schema.Types.ObjectId, required: yes}
	is-disabled: {type: Boolean,               required: no, default: no}

module.exports = db.model \StatusImage status-image-schema
