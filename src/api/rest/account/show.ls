require! {
	'../../auth': authorize
	'../../../models/utils/filter-user-for-response'
}
module.exports = (req, res) -> authorize req, res, (user, app) -> res.api-render filter-user-for-response user
