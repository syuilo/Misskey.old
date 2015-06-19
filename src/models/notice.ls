# Types:
#  self-notice (text)
#  follow (user-id) フォローされました
#  status-reply (reply-id, status-id, user-id) つぶやきに返信が付きました
#  status-repost (status-id, user-id) つぶやきがRepostされました
#  status-favorite (status-id, user-id) つぶやきがふぁぼられました
#  talk-message (message-id, user-id) トーク メッセージが届きました
#  article-comment (comment-id, article-id, user-id) 記事にコメントが付きました
#  article-favorite (article-id, user-id) 記事がふぁぼられました
#  article-publish (article-id, user-id) フォローしているユーザーの記事が公開されました

require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

schema = new Schema do
	content:    {type: Schema.Types.Mixed,    required: no, default: {}}
	created-at: {type: Date,                  default: Date.now}
	type:       {type: String}
	user-id:    {type: Schema.Types.ObjectId, required: yes}

module.exports = db.model \Notice schema
