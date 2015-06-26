require! {
	moment
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

schema = new Schema do
	created-at:      {type: Date,                  required: yes, default: Date.now}
	tags:            {type: [String],              required: no,  default: []}
	title:           {type: String,                required: yes}
	user-id:         {type: Schema.Types.ObjectId, required: yes}
	watchers-count:  {type: Number,                required: yes, default: 0}
	favorites-count: {type: Number,                required: yes, default: 0}
	
if !schema.options.to-object then schema.options.to-object = {}
schema.options.to-object.transform = (doc, ret, options) ->
	ret.id = doc.id
	ret.created-at = moment doc.created-at .format 'YYYY/MM/DD HH:mm:ss Z'
	delete ret._id
	delete ret.__v
	ret

module.exports = db.model \BBSThread schema
