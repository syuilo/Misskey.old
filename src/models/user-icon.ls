require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

user-icon-schema = new Schema do
	image: { type: Buffer, default: null }

module.exports = db.model \UserIcon user-icon-schema
