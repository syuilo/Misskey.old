require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

schema = new Schema do
	items:   {type: Schema.Types.Mixed,    required: no, default: {}}
	user-id: {type: Schema.Types.ObjectId, required: yes}

module.exports = db.model \UserRoom schema
