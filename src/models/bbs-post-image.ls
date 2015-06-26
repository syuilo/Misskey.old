require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

schema = new Schema do
	image:   {type: Buffer}
	post-id: {type: Schema.Types.ObjectId, required: yes}

module.exports = db.model \BBSPostImage schema
