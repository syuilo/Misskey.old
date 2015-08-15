require! {
	'../config'
	'../models/api-access-log': APIAccessLog
	'../models/user': User
}

# Limitter
# user-id: 対象ユーザー(ID)
# endpoint: 対象API名
# limit-period: リミットカウント期間
# limit-max: 上記のリミットカウント期間内にどれだけの利用を許すかの数
module.exports = (user-id, endpoint, limit-period, limit-max) ->
	resolve, reject <- new Promise!
	
	# ログ引き出し
	(err, log) <- APIAccessLog.find {user-id, endpoint} 
	# ログが存在した場合
	if log?
		last = log.reseted-at.get-time! / 1000 # 最終リミットカウントリセット日時(秒)
		now = (new Date!).get-time! / 1000 # 現在日時(秒)
		# リミット計測の期間を過ぎていた場合
		if (now - last) >= limit-period
			# リミットカウントリセット
			log.count = 1
			log.reseted-at = new Date!
			log.save!
			resolve! # Done!
		# リミット計測期間内
		else
			# リミットを超過する場合
			if log.count >= limit-max
				reject! # Failed...
			# まだ大丈夫な場合
			else
				# カウントを増やす
				log.count++
				log.save!
				resolve! # Done!
	# ログが存在しなかった場合(初回API利用時)
	else
		# ログ作成
		new-log = new APIAccessLog {user-id, endpoint}
		# 保存
		err, created-log <- new-log.save
		resolve! # Done!