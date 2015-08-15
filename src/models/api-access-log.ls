require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

schema = new Schema do
	updated-at: {type: Date,                  required: no, default: Date.now}
	count:      {type: Number,                required: no, default: 0}
	endpoint:   {type: String,                required: yes, default: null}
	user-id:    {type: Schema.Types.ObjectId, required: yes}

module.exports = db.model \APIAccessLog schema
