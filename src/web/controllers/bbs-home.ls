require! {
	'../../models/bbs-thread': BBSThraed
	'../../models/utils/get-hot-threads'
	'../../models/utils/get-recent-threads'
}

module.exports = (req, res) ->
	res.display req, res, \bbs-home {
	}
