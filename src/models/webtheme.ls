require! {
	mongoose
	'../config'
}

db = mongoose.create-connection config.mongo.uri, config.mongo.options

webtheme-schema = new mongoose.Schema do
	created-at:  {type: Date, default: Date.now}
	description: {type: String}
	name:        {type: String, required: yes}
	style:       {}
	user-id:     {type: Number, required: yes}
	
module.exports = db.model \Webtheme webtheme-schema
