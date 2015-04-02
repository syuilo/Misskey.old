require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

status-favorite-schema = new Schema do
	created-at: {type: Date,                  default: Date.now}
	status-id:  {type: Schema.Types.ObjectId, required: yes}
	user-id:    {type: Schema.Types.ObjectId, required: yes}

module.exports = db.model \StatusFavorite status-favorite-schema
