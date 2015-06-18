require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

schema = new Schema do
	app-id:     {type: Schema.Types.ObjectId, required: yes}
	content:    {type: Schema.Types.Mixed,    required: no, default: {}}
	created-at: {type: Date,                  default: Date.now}
	type:       {type: String}
	user-id:    {type: Schema.Types.ObjectId, required: yes}

module.exports = db.model \Notice schema
