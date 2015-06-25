require! {
	'../../models/bbs-thread': BBSThraed
	'../../models/utils/get-hot-threads'
	'../../models/utils/get-recent-threads'
}

module.exports = (req, res) ->
	hot-threads <- get-hot-threads .then
	recent-threads <- get-recent-threads .then
	res.display req, res, \bbs-home {
		hot-threads
		recent-threads
	}
