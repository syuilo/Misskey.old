require! {
	mongoose
	'../../config': config
}

db = mongoose.connect config.mongo.uri, config.mongo.options

user-schema = new mongoose.Schema do
	bio: { type: String }
	birthday: { type: String }
	color: { type: String, default: '#ff005c', required: true }
	comment: { type: String }
	created-at: { type: Date, default: Date.now, required: true }
	emailaddress: { type: Number }
	exp: { type: String }
	first-name: { type: String }
	gender: { type: String }
	is-plused: { type: Boolean, default: false }
	is-suspended: { type: Boolean, default: false }
	lang: { type: String, default: 'ja', required: true }
	last-name: { type: String }
	links: { type: [String] }
	location: { type: String }
	lv: { type: Number }
	name: { type: String }
	password: { type: String, required: true }
	screen-name: { type: String, required: true }
	tags: { type: [String] }
	url: { type: String }
	using-web-theme-id: { type: Number }

module.exports = db.model 'User' user-schema
