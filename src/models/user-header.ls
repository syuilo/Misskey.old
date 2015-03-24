require! {
	mongoose
	'../config'
}

db = mongoose.create-connection config.mongo.uri, config.mongo.options

user-header-schema = new mongoose.Schema do
	image: { type: Buffer, default: null }
	user-id: { type: Number, required: yes }

module.exports = db.model \UserHeader user-header-schema
