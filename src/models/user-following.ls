require! {
	mongoose
	'../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

user-following-schema = new mongoose.Schema do
	created-at: { type: Date, default: Date.now }
	followee-id: { type: Number, required: true }
	follower-id: { type: Number, required: true }

exports = db.model \UserFollowing user-following-schema
