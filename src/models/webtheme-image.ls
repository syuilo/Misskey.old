require! {
	mongoose
	'../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

webtheme-thumbnail-schema = new mongoose.Schema do
	thumbnail: { type: Buffer, default: null }
	webtheme-id: { type: Number, required: yes }
	
module.exports = db.model \WebthemeThumbnail webtheme-thumbnail-schema
