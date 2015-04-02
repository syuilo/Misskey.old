div(class= 'message ' + (message.userId == me.id ? 'me' : 'otherparty')
		title!= '#{message.createdAt}&#x0A;via #{message.app.name}'
		data-id= message.id
		data-is-readed!= message.isReaded.toString()
		data-is-deleted!= message.isDeleted.toString()
		data-user-id= message.user.id
		data-user-color= message.user.color)
	article
		a.iconAnchor(href= url + '/' + message.user.screenName, title= message.user.comment)
			img.icon(src=url + '/img/icon/' + message.user.screenName, alt='icon')
		div.contentContainer
			if !message.isDeleted && (message.userId == me.id)
				if message.isReaded
					p.readed 既読
				button.deleteButton(role='button', title='メッセージを削除')
					img(src='/resources/images/destroy.png', alt='Delete')
			div.content
				if !message.isDeleted
					p.text!= parseText(message.text)
					if message.isImageAttached
						img.image(src=url + '/img/talk-message/' + message.id, alt='image')
				else
					p.isDeleted このメッセージは削除されました
			time(datetime=message.createdAt)= message.createdAt