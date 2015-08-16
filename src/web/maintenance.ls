################################
# Maintenance Server
################################

require! {
	fs
	https
	express
	jade
	'../config'
}

read-file = (path) -> fs.read-file-sync path .to-string!
message = jade.render-file "#__dirname/maintenance.jade"

# Read certs
certs =
	key: read-file "#__dirname/../../../../certs/server.key"
	cert: read-file "#__dirname/../../../../certs/startssl.crt"
	ca: read-file "#__dirname/../../../../certs/sub.class1.server.ca.pem"

# Init express
app = express!
app.disable \x-powered-by

app.all '*' (req, res) ->
	res.status 503
	res.send message

# Listen HTTPS server after create 
https.create-server certs, app .listen config.port.web-https

# Redirect HTTP
http-app = express!
http-app.disable \x-powered-by
http-app.all '*' (req, res, next) ->
	res.redirect 'https://misskey.xyz'
http-app.listen config.port.web-http