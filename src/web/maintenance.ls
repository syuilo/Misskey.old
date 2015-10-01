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

# Init express
app = express!
app.disable \x-powered-by

app.all '*' (req, res) ->
	res.status 503
	res.send message

app.listen config.port.web-http
