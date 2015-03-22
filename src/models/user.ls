require! {
	mongoose
	'../../config'
}

db = mongoose.connect config.mongo.uri, config.mongo.options

user-schema = new mongoose.Schema do
	bio: { type: String, default: null }
	birthday: { type: String, default: null }
	color: { type: String, default: '#ff005c', required: yes }
	comment: { type: String, default: null }
	created-at: { type: Date, default: Date.now, required: yes }
	emailaddress: { type: String, default: null }
	first-name: { type: String, default: null }
	followers-count: { type: Number, default: 0 }
	friends-count: { type: Number, default: 0 }
	gender: { type: String, default: null }
	is-plused: { type: Boolean, default: no }
	is-suspended: { type: Boolean, default: no }
	lang: { type: String, default: 'ja', required: yes }
	last-name: { type: String, default: null }
	links: { type: [String], default: null }
	location: { type: String, default: null }
	name: { type: String, required: yes }
	password: { type: String, required: yes }
	screen-name: { type: String, required: yes }
	statuses-count: { type: Number, default: 0 }
	tags: { type: [String], default: null }
	url: { type: String, default: null }
	using-webtheme-id: { type: Number, default: null }

exports = db.model \User user-schema
