require! {
	moment
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

user-schema = new Schema do
	bio:                    {type: String,   required: no,  default: null}
	birthday:               {type: String,   required: no,  default: null}
	color:                  {type: String,   required: yes}
	comment:                {type: String,   required: no,  default: null}
	created-at:             {type: Date,     required: yes, default: Date.now}
	emailaddress:           {type: String,   required: no,  default: null}
	first-name:             {type: String,   required: no,  default: null}
	followers-count:        {type: Number,   required: no,  default: 0}
	followings-count:       {type: Number,   required: no,  default: 0}
	gender:                 {type: String,   required: no,  default: null}
	is-plus:                {type: Boolean,  required: no,  default: no}
	is-suspended:           {type: Boolean,  required: no,  default: no}
	lang:                   {type: String,   required: no,  default: \ja}
	last-name:              {type: String,   required: no,  default: null}
	links:                  {type: [String], required: no,  default: []}
	location:               {type: String,   required: no,  default: null}
	name:                   {type: String,   required: yes}
	password:               {type: String,   required: yes}
	screen-name:            {type: String,   required: yes, unique: yes}
	screen-name-lower:      {type: String,   required: yes, unique: yes}
	statuses-count:         {type: Number,   required: no,  default: 0}
	status-favorites-count: {type: Number,   required: no,  default: 0}
	tags:                   {type: [String], required: no,  default: []}
	url:                    {type: String,   required: no,  default: null}
	using-webtheme-id:      {type: Number,   required: no,  default: null}

if !user-schema.options.to-object then user-schema.options.to-object = {}
user-schema.options.to-object.transform = (doc, ret, options) ->
	ret.id = doc.id
	ret.created-at = moment doc.created-at .format 'YYYY/MM/DD HH:mm:ss Z'
	delete ret.password
	delete ret.emailaddress
	ret

module.exports = db.model \User user-schema
