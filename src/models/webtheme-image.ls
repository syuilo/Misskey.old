require! {
	mongoose
	'../config'
}

db = mongoose.create-connection config.mongo.uri, config.mongo.options

webtheme-thumbnail-schema = new mongoose.Schema do
	thumbnail: {type: Buffer, default: null}
	webtheme-id: {type: Number, required: yes}
	
module.exports = db.model \WebthemeThumbnail webtheme-thumbnail-schema
