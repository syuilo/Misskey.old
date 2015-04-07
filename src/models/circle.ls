require! {
	mongoose
	'../config'
}

db = mongoose.create-connection config.mongo.uri, config.mongo.options

circle-join-request-schema = new mongoose.Schema do
	created-at: {type: Date,   required: yes, default: Date.now}
	user-id:    {type: Number, required: yes}

circle-member-schema = new mongoose.Schema do
	user-id:                 {type: Number,  required: yes }
	created-at:              {type: Date,    required: no,  default: Date.now}
	title:                   {type: String,  required: no,  default: null}
	is-master:               {type: Boolean, required: no,  default: no}
	is-executive:            {type: Boolean, required: no,  default: no}
	can-select-join-request: {type: Boolean, required: no,  default: no}
	can-exclude-member:      {type: Boolean, required: no,  default: no}
	can-create-thread:       {type: Boolean, required: no,  default: no}
	can-create-note:         {type: Boolean, required: no,  default: no}

circle-schema = new mongoose.Schema do
	created-at:    {type: Date,   required: no, default: Date.now}
	description:   {type: String, required: no, default: null}
	join-requests: [circle-join-request-schema]
	members:       [circle-member-schema]
	name:          {type: String, required: yes}
	screen-name:   {type: String, required: yes, unique: yes}
	user-id:       {type: Number, required: yes}

module.exports = db.model \Circle circle-schema
