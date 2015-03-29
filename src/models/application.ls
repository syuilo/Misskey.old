require! {
	mongoose
	'../config'
}

db = mongoose.create-connection config.mongo.uri, config.mongo.options

application-schema = new mongoose.Schema do
	name: { type: String, required: yes }
	user-id: { type: Number, required: yes }
	created-at: { type: Date, default: Date.now }
	consumer-key: { type: String }
	callback-url: { type: String }
	description: { type: String, required: yes }
	developer-name: { type: String }
	developer-website: { type: String }
	is-suspended: { type: Boolean }

if !application-schema.options.to-object then application-schema.options.to-object = {}
application-schema.options.to-object.transform = (doc, ret, options) ->
	ret.id = doc.id
	ret

module.exports = db.model \Application application-schema
