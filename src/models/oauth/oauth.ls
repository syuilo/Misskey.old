#
# OAuth model
#

require! {
	mongoose
	'../application': Application
	'../user': User
	'./access-token': OAuthAccessToken
	'../../config'
}

Schema = mongoose.Schema

model = module.exports

#
# oauth2-server callbacks
#
model.get-access-token = (bearer-token, callback) ->
	OAuthAccessToken.find-one { access-token: bearer-token } callback

model.get-client = (app-id, client-secret, callback) ->
	| client-secret? => Application.find-one { id: app-id, secret: client-secret } callback
	| _ => Application.find-by-id app-id, callback

model.save-access-token = (token, app-id, expires, user-id, callback) ->
	access-token = new OAuthAccessToken do
	{
		token
		app-id
		user-id
		expires
	}
	access-token.save callback
