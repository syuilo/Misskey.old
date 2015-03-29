require! {
	mongoose
	'../../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

oauth-access-token-schema = new Schema do
	token:   { type: String }
	app-id:  { type: Schema.Types.ObjectId }
	user-id: { type: Schema.Types.ObjectId }
	expires: { type: Date }

module.exports = db.model \OAuthAccessTokens oauth-access-token-schema
