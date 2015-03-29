require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

user-schema = new Schema do
	bio:                    { type: String,   required: no,  default: null }
	birthday:               { type: String,   required: no,  default: null }
	color:                  { type: String,   required: yes }
	comment:                { type: String,   required: no,  default: null }
	created-at:             { type: Date,     required: yes, default: Date.now }
	emailaddress:           { type: String,   required: no,  default: null }
	first-name:             { type: String,   required: no,  default: null }
	followers-count:        { type: Number,   required: no,  default: 0 }
	followings-count:       { type: Number,   required: no,  default: 0 }
	gender:                 { type: String,   required: no,  default: null }
	is-plus:                { type: Boolean,  required: no,  default: no }
	is-suspended:           { type: Boolean,  required: no,  default: no }
	lang:                   { type: String,   required: no, default: 'ja' }
	last-name:              { type: String,   required: no,  default: null }
	links:                  { type: [String], required: no,  default: null }
	location:               { type: String,   required: no,  default: null }
	name:                   { type: String,   required: yes }
	password:               { type: String,   required: yes }
	screen-name:            { type: String,   required: yes, unique: yes }
	statuses-count:         { type: Number,   required: no,  default: 0 }
	status-favorites-count: { type: Number,   required: no,  default: 0 }
	tags:                   { type: [String], required: no,  default: null }
	url:                    { type: String,   required: no,  default: null }
	using-webtheme-id:      { type: Number,   required: no,  default: null }

user-schema.options.to-object.transform = (doc, ret, options) ->
	ret.id = doc.id

module.exports = db.model \User user-schema
