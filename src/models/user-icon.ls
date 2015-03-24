require! {
	mongoose
	'../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

user-icon-schema = new mongoose.Schema do
	image: { type: Buffer, default: null }
	user-id: { type: Number, required: yes }

exports = db.model \UserIcon user-icon-schema
