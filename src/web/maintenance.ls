################################
# Maintenance Server
################################

require! {
	fs
	https
	jade
	'../config'
}

read-file = (path) -> fs.read-file-sync path .to-string!
message = jade.render-file "#{__dirname}/maintenance.jade"

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

# Create after listen HTTPS server
server = https.create-server certs, app
server.listen config.port.web-https
