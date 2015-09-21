require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

schema = new Schema do
	layout:     {type: Schema.Types.Mixed,    required: yes}
	user-id:    {type: Schema.Types.ObjectId, required: yes}

module.exports = db.model \UserHomeLayout schema
