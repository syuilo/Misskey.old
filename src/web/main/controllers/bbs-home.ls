require! {
	'../../../models/bbs-thread': BBSThraed
	'../../../models/utils/get-bbs-hot-threads'
	'../../../models/utils/get-bbs-recent-threads'
}

module.exports = (req, res) ->
	hot-threads <- get-bbs-hot-threads .then
	recent-threads <- get-bbs-recent-threads .then
	res.display req, res, \bbs-home {
		hot-threads
		recent-threads
	}
