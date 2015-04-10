require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

webtheme-schema = new Schema do
	created-at:  {type: Date,                  required: yes, default: Date.now}
	description: {type: String,                required: yes}
	name:        {type: String,                required: yes}
	style:       {}
	user-id:     {type: Schema.Types.ObjectId, required: yes}

module.exports = db.model \Webtheme webtheme-schema
