require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

user-following-schema = new Schema do
	created-at:  { type: Date, default: Date.now }
	followee-id: { type: Schema.Types.ObjectId, required: yes }
	follower-id: { type: Schema.Types.ObjectId, required: yes }

module.exports = db.model \UserFollowing user-following-schema
