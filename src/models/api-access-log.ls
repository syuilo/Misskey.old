require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

schema = new Schema do
	reseted-at: {type: Date,                  required: no, default: Date.now}
	count:      {type: Number,                required: no, default: 1}
	endpoint:   {type: String,                required: yes}
	user-id:    {type: Schema.Types.ObjectId, required: yes}

module.exports = db.model \APIAccessLog schema
