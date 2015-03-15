require! {
	'../../auth': authorize
}
module.exports = (req, res) -> authorize req, res, (user, app) -> res.apiRender user.filt!
