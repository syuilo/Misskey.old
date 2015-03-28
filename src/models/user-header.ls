require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

user-header-schema = new Schema do
	image: { type: Buffer, default: null }

module.exports = db.model \UserHeader user-header-schema
