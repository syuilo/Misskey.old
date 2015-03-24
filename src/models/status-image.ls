require! {
	mongoose
	'../config'
}

db = mongoose.create-connection config.mongo.uri, config.mongo.options

status-image-schema = new mongoose.Schema do
	image: { type: Buffer, default: null }
	status-id: { type: Number, required: yes }

module.exports = db.model \StatusImage status-image-schema
