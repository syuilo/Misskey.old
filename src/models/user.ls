require! {
	mongoose
	'../../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

user-schema = new mongoose.Schema do
	bio: { type: String }
	birthday: { type: String }
	color: { type: String, default: '#ff005c', required: yes }
	comment: { type: String }
	created-at: { type: Date, default: Date.now, required: yes }
	emailaddress: { type: Number }
	exp: { type: String }
	first-name: { type: String }
	followers-count: { type: Number, default: 0 }
	friends-count: { type: Number, default: 0 }
	gender: { type: String }
	is-plused: { type: Boolean, default: no }
	is-suspended: { type: Boolean, default: no }
	lang: { type: String, default: 'ja', required: yes }
	last-name: { type: String }
	links: { type: [String] }
	location: { type: String }
	lv: { type: Number }
	name: { type: String }
	password: { type: String, required: yes }
	screen-name: { type: String, required: yes }
	tags: { type: [String] }
	url: { type: String }
	using-webtheme-id: { type: Number }

exports = db.model \User user-schema
