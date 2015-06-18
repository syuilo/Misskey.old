# Types:
#  follow フォローされました
#  status-reply つぶやきに返信が付きました
#  status-repost つぶやきがRepostされました
#  status-favorite つぶやきがふぁぼられました
#  talk-message トーク メッセージが届きました
#  article-comment 記事にコメントが付きました
#  article-favorite 記事がふぁぼられました
#  article-publish フォローしているユーザーの記事が公開されました

require! {
	mongoose
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

schema = new Schema do
	app-id:     {type: Schema.Types.ObjectId, required: yes}
	content:    {type: Schema.Types.Mixed,    required: no, default: {}}
	created-at: {type: Date,                  default: Date.now}
	type:       {type: String}
	user-id:    {type: Schema.Types.ObjectId, required: yes}

module.exports = db.model \Notice schema
