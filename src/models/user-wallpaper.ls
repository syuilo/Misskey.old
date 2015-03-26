require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

user-wallpaper-schema = new Schema do
	image: { type: Buffer, default: null }
	user-id: { type: Schema.Types.ObjectId, required: yes }

module.exports = db.model \UserWallpaper user-wallpaper-schema
