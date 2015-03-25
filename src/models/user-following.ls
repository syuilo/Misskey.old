require! {
	mongoose
	'../config'
}

db = mongoose.create-connection config.mongo.uri, config.mongo.options

user-following-schema = new mongoose.Schema do
	created-at: { type: Date, default: Date.now }
	followee-id: { type: Number, required: yes }
	follower-id: { type: Number, required: yes }

module.exports = db.model \UserFollowing user-following-schema
