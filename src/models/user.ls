require! {
	moment
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

schema = new Schema do
	bio:                     {type: String,                required: no,  default: null}
	birthday:                {type: String,                required: no,  default: null}
	color:                   {type: String,                required: yes}
	comment:                 {type: String,                required: no,  default: null}
	created-at:              {type: Date,                  required: yes, default: Date.now}
	emailaddress:            {type: String,                required: no,  default: null}
	first-name:              {type: String,                required: no,  default: null}
	followers-count:         {type: Number,                required: no,  default: 0}
	followings-count:        {type: Number,                required: no,  default: 0}
	gender:                  {type: String,                required: no,  default: null}
	is-display-not-follow-user-mention: {type: Boolean,    required: no,  default: yes}
	is-plus:                 {type: Boolean,               required: no,  default: no}
	is-suspended:            {type: Boolean,               required: no,  default: no}
	is-verified:             {type: Boolean,               required: no,  default: no}
	lang:                    {type: String,                required: no,  default: \ja}
	last-name:               {type: String,                required: no,  default: null}
	links:                   {type: [String],              required: no,  default: []}
	location:                {type: String,                required: no,  default: null}
	name:                    {type: String,                required: yes}
	password:                {type: String,                required: yes}
	screen-name:             {type: String,                required: yes, unique: yes}
	screen-name-lower:       {type: String,                required: yes, unique: yes}
	statuses-count:          {type: Number,                required: no,  default: 0}
	status-favorites-count:  {type: Number,                required: no,  default: 0}
	tags:                    {type: [String],              required: no,  default: []}
	url:                     {type: String,                required: no,  default: null}
	using-webtheme-id:       {type: Schema.Types.ObjectId, required: no,  default: null}
	mobile-header-design-id: {type: String,                required: no,  default: null}
	icon-image:              {type: String,                required: no,  default: null}
	banner-image:            {type: String,                required: no,  default: null}
	wallpaper-image:         {type: String,                required: no,  default: null}

schema.virtual \iconImageUrl .get ->
	"#{config.image-server-url}/#{this.icon-image}"

schema.virtual \bannerImageUrl .get ->
	"#{config.image-server-url}/#{this.banner-image}"

schema.virtual \blurredBannerImageUrl .get ->
	"#{config.image-server-url}/#{this.banner-image.replace '.jpg' '-blurred.jpg'}"

schema.virtual \wallpaperImageUrl .get ->
	"#{config.image-server-url}/#{this.wallpaper-image}"

schema.virtual \blurredWallpaperImageUrl .get ->
	"#{config.image-server-url}/#{this.wallpaper-image.replace '.jpg' '-blurred.jpg'}"

if !schema.options.to-object then schema.options.to-object = {}
schema.options.to-object.transform = (doc, ret, options) ->
	ret.id = doc.id
	ret.created-at = moment doc.created-at .format 'YYYY/MM/DD HH:mm:ss Z'
	ret.icon-image-url = "#{config.image-server-url}/#{doc.icon-image}"
	ret.banner-image-url = "#{config.image-server-url}/#{doc.banner-image}"
	ret.wallpaper-image-url = "#{config.image-server-url}/#{doc.wallpaper-image}"
	delete ret.icon-image
	delete ret.banner-image
	delete ret.wallpaper-image
	delete ret._id
	delete ret.__v
	delete ret.password
	delete ret.emailaddress
	ret

module.exports = db.model \User schema
