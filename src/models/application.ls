require! {
	moment
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

schema = new Schema do
	name:              {type: String,                required: yes}
	user-id:           {type: Schema.Types.ObjectId, required: yes}
	created-at:        {type: Date,                  required: yes, default: Date.now}
	app-key:           {type: String,                required: yes, unique: yes}
	callback-url:      {type: String,                required: no,  default: null}
	description:       {type: String,                required: yes}
	developer-name:    {type: String,                required: no,  default: null}
	developer-website: {type: String,                required: no,  default: null}
	is-suspended:      {type: Boolean,               required: no,  default: no}
	icon-image:        {type: String,                required: no,  default: null}
	permissions:       {type: [String],              required: no,  default: []}
	screen-id:         {type: String,                required: yes, unique: yes}
	screen-id-lower:   {type: String,                required: yes, unique: yes}

schema.virtual \iconImageUrl .get ->
	"#{config.image-server-url}/#{this.icon-image}"

if !schema.options.to-object then schema.options.to-object = {}
schema.options.to-object.transform = (doc, ret, options) ->
	ret.id = doc.id
	ret.icon-image-url = "#{config.image-server-url}/#{doc.icon-image}"
	#ret.created-at = moment doc.created-at .format 'YYYY/MM/DD HH:mm:ss Z'
	ret

module.exports = db.model \Application schema
