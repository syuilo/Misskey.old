# Types:
#  self-notice (text)
#  follow (user-id) フォローされました
#  status-reply (reply-id, status-id, user-id) つぶやきに返信が付きました
#  status-repost (repost-id, status-id, user-id) つぶやきがRepostされました
#  status-favorite (status-id, user-id) つぶやきがふぁぼられました
#  talk-message (message-id, user-id) トーク メッセージが届きました
#  article-comment (comment-id, article-id, user-id) 記事にコメントが付きました
#  article-favorite (article-id, user-id) 記事がふぁぼられました
#  article-publish (article-id, user-id) フォローしているユーザーの記事が公開されました

require! {
	mongoose
	'mongoose-auto-increment'
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

mongoose-auto-increment.initialize db

schema = new Schema do
	content:    {type: Schema.Types.Mixed,    required: no, default: {}}
	created-at: {type: Date,                  default: Date.now}
	cursor:     {type: Number}
	type:       {type: String}
	user-id:    {type: Schema.Types.ObjectId, required: yes}

if !schema.options.to-object then schema.options.to-object = {}
schema.options.to-object.transform = (doc, ret, options) ->
	ret.id = doc.id
	delete ret._id
	delete ret.__v
	ret

# Auto increment
schema.plugin mongoose-auto-increment.plugin, {model: \Notice, field: \cursor}

module.exports = db.model \Notice schema
