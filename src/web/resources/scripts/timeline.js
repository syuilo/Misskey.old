var TIMELINE = {};

TIMELINE.generatePostElement = function(post) {
	return $('<li class="status post">')
	.attr({
		title: post.createdAt + '&#x0A;via ' + post.app.name,
		'data-id': post.id,
		'data-user-id': post.userId,
		'data-user-color': post.user.color,
		'data-user-verified': post.user.isPremium.toString(),
		'data-is-reply': post.isReply.toString(),
		'data-is-talk': (post.moreTalk != null).toString(),
		'data-is-favorited': 'false',
		'data-is-reposted': 'false',
		'data-is-repostpost': post.isRepostToPost ? 'true' : 'false',
		style: post.isReply ? 'border-color: ' + post.reply.user.color + ';' : ''
	})
	.append(post.moreTalk != null ? generateTalk() : null)
	.append(post.isRepostToPost ? generateRepostInformation() : null)
	.append(post.isReply ? generateReplyTo() : null)
	.append(generateArticle(post, false))
	.append(generateFooter());

	function generateTalk() {
		return $('<div class="moreTalk">')
		.append($('<i class="fa fa-ellipsis-v">'))
		.append(generateTalkPostsList());

		function generateTalkPostsList() {
			var ol = $('<ol class="talk">');
			post.moreTalk.forEach(function(talkPost) {
				ol.append($('<li class="post">')
					.attr('data-user-verified', talkPost.user.isPremium.toString())
					.append(generateArticle(talkPost, true)));
			});
			return ol;
		}
	}

	function generateRepostInformation() {
		return $('<div class="repostInformation">')
		.append(generateInfo());

		function generateInfo() {
			return $('<p class="info">')
			.append($('<a class="iconAnchor">')
				.attr('href', conf.url + '/' + post.repostedByUser.screenName + '/talk?noheader=true')
				.attr('title', post.repostedByUser.comment != null ? post.repostedByUser.comment : '@' + post.repostedByUser.screenName)
				.append(
					$('<img class="icon" alt="icon">').attr('src', conf.url + '/img/icon/' + post.repostedByUser.screenName)))
			.append($('<i class="fa fa-retweet">'))
			.append($('<a class="name" target="_blank">').attr('href', conf.url + '/' + post.repostedByUser.screenName).text(post.repostedByUser.name))
			.append('によってRepost');
		}
	}

	function generateReplyTo() {
		return $('<div class="replyTo">')
		.attr('data-user-verified', post.reply.user.isPremium.toString())
		.append(generateArticle(post.reply, true));
	}

	function generateArticle(post, isReplyToNode) {
		return $('<article>')
		.append(generateIcon())
		.append(generateHeader())
		.append(generateMain())
		.append(!isReplyToNode ? generateFooter() : null);

		function generateIcon() {
			return $('<a class="iconAnchor">')
			.attr('href', conf.url + '/' + post.user.screenName + '/talk?noheader=true')
			.attr('title', post.user.comment != null ? post.user.comment : '@' + post.user.screenName)
			.append(
			$('<img class="icon" alt="icon">')
			.attr('src', conf.url + '/img/icon/' + post.user.screenName)
			);
		}

		function generateHeader() {
			return generateHeader()
			.append(generateScreenName())
			.append(generateTime());

			function generateHeader() {
				return $('<header>').prepend($('<h2>').prepend(generateName()));
			}

			function generateName() {
				return $('<a target="_blank">')
				.attr('href', conf.url + '/' + post.user.screenName)
				.text(escapeHtml(post.user.name));
			}

			function generateScreenName() {
				return $('<span class="screenName">')
				.text('@' + post.user.screenName);
			}

			function generateTime() {
				return $('<a>')
				.attr('href', conf.url + '/' + post.user.screenName + '/' + post.id)
				.append(
					$('<time>')
					.attr('datetime', post.createdAt)
					.text(post.createdAt));
			}
		}

		function generateMain() {
			return $('<div class="main">')
			.append($('<p class="text">').html((post.isReply ? '<a href="' + conf.url + '/post/' + post.inReplyToPostId + '" class="reply"><i class="fa fa-reply"> </i></a>' : '') + parseText(post.text)))
			.append(post.isImageAttached ? generateImage() : null);

			function generateImage() {
				return $('<img alt="image" class="image">')
				.attr('src', conf.url + '/img/post/' + post.id);
			}
		}

		function generateFooter() {
			return $('<footer>')
			.append(generateActions());

			function generateActions() {
				return $('<div class="actions">')
				.append(generateRepost())
				.append(generateFavorite());

				function generateRepost() {
					return $('<div class="repost">')
					.append(generateRepostButton())
					.append($('<a class="count">').attr('href', conf.url + '/' + post.user.screenName + '/' + post.id + '/reposts'));

					function generateRepostButton() {
						return $('<button class="repostButton" title="Repost" role="button">')
						.append($('<i class="fa fa-retweet">'));
					}
				}

				function generateFavorite() {
					return $('<div class="favorite">')
					.append(generateFavoriteButton())
					.append($('<a class="count">').attr('href', conf.url + '/' + post.user.screenName + '/' + post.id + '/favorites'));

					function generateFavoriteButton() {
						return $('<button class="favoriteButton" title="お気に入り" role="button">')
						.append($('<i class="fa fa-star">'));
					}
				}
			}
		}
	}

	function generateFooter() {
		return $('<footer>')
		.append(generateForm());

		function generateForm() {
			return $('<form class="replyForm">')
			.append(generateTextArea())
			.append(generateInReplyToPostId())
			.append(generateSubmitButton())
			.append(generateImageAttacher());

			function generateTextArea() {
				return $('<textarea name="text">')
				.text('@' + post.user.screenName + ' ');
			}

			function generateInReplyToPostId() {
				return $('<input name="in_reply_to_post_id" type="hidden">')
				.attr('value', post.id);
			}

			function generateSubmitButton() {
				return $('<input type="submit" value="&#xf112; Reply" class="fa fa-reply">');
			}

			function generateImageAttacher() {
				return $('<div class="imageAttacher">')
				.append($('<p><i class="fa fa-picture-o"></i></p>'))
				.append($('<input name="image" type="file" accept="image/*">'));
			}
		}
	}

	function parseText(text) {
		text = escapeHtml(text);
		text = parsePre(text);
		text = parseURL(text);
		text = parseReply(text);
		text = parseBold(text);
		text = parseSmall(text);
		text = parseNewLine(text);
		return text;

		function parsePre(text) {
			return text.replace(/'''(.+?)'''/g, function(_, word) {
				return '<pre>' + word + '</pre>';
			});
		}

		function parseURL(text) {
			return text.replace(/https?:\/\/[-_.!~*a-zA-Z0-9;\/?:\@&=+\$,%#]+/g, function(url) {
				return '<a href="' + url + '" target="_blank" class="url">' + url + '</a>';
			});
		}

		function parseReply(text) {
			return text.replace(/@([a-zA-Z0-9_]+)/g, function(_, screenName) {
				return '<a href="' + conf.url + '/' + screenName + '" target="_blank" class="screenName">@' + screenName + '</a>';
			});
		}

		function parseBold(text) {
			return text.replace(/\*\*(.+?)\*\*/g, function(_, word) {
				return '<b>' + word + '</b>';
			});
		}

		function parseSmall(text) {
			return text.replace(/\(\((.+?)\)\)/g, function(_, word) {
				return '<small>(' + word + ')</small>';
			});
		}

		function parseNewLine(text) {
			return text.replace(/(\r\n|\r|\n)/g, '<br>');
		}
	}

	function escapeHtml(text) {
		return $('<div>').text(text).html();
	}
}

TIMELINE.setEventPost = function($post) {
	$post.children('article').children('a').click(function() {
		var windowId = 'misskey-window-talk-' + $post.attr('data-user-id');
		var url = $post.children('article').children('a').attr('href');
		var $content = $("<iframe>").attr({ src: url, seamless: true });
		openWindow(windowId, $content, '<i class="fa fa-comments"></i>' + $post.children('article').children('header').children('h2').children('a').text(), 300, 450, true, url);
		return false;
	});

	$post.find('.replyForm').submit(function(event) {
		event.preventDefault();
		var $form = $(this);
		var $submitButton = $form.find('[type=submit]');
		$submitButton.attr('disabled', true);
		$.ajax({
			url: 'https://api.misskey.xyz/post/create',
			type: 'post',
			data: new FormData($form[0]),
			processData: false,
			contentType: false,
			dataType: 'json',
			xhrFields: {
				withCredentials: true
			}
		}).done(function() {
			$submitButton.attr('disabled', false);
			$form.text('送信しました');
		}).fail(function() {
			$submitButton.attr('disabled', false);
		});
	});

	$post.find('.imageAttacher input[name=image]').change(function() {
		var $input = $(this);
		var file = $(this).prop('files')[0];
		if (!file.type.match('image.*')) return;
		var reader = new FileReader();
		reader.onload = function() {
			var $img = $('<img>').attr('src', reader.result);
			$input.parent('.imageAttacher').find('p, img').remove();
			$input.parent('.imageAttacher').append($img);
		};
		reader.readAsDataURL(file);
	});

	$post.find('article > footer > .actions > .favorite > .favoriteButton').click(function() {
		var $button = $(this);
		$button.attr('disabled', true);

		if ($post.attr('data-is-favorited') == 'true') {
			$post.attr('data-is-favorited', 'false')
			$.ajax('https://api.misskey.xyz/post/unfavorite', {
				type: 'delete',
				data: { 'post_id': $post.attr('data-id') },
				dataType: 'json',
				xhrFields: { withCredentials: true }
			}).done(function() {
				$button.attr('disabled', false);
			}).fail(function() {
				$button.attr('disabled', false);
				$post.attr('data-is-favorited', 'true')
			});
		} else {
			$post.attr('data-is-favorited', 'true')
			$.ajax('https://api.misskey.xyz/post/favorite', {
				type: 'post',
				data: { 'post_id': $post.attr('data-id') },
				dataType: 'json',
				xhrFields: { withCredentials: true }
			}).done(function() {
				$button.attr('disabled', false);
			}).fail(function() {
				$button.attr('disabled', false);
				$post.attr('data-is-favorited', 'false')
			});
		}
	});

	$post.find('article > footer > .actions > .repost > .repostButton').click(function() {
		var $button = $(this);
		$button.attr('disabled', true);

		if ($post.attr('data-is-reposted') == 'true') {
			$.ajax('https://api.misskey.xyz/post/unrepost', {
				type: 'delete',
				data: { 'post_id': $post.attr('data-id') },
				dataType: 'json',
				xhrFields: { withCredentials: true }
			}).done(function() {
				$button.attr('disabled', false);
				$post.attr('data-is-reposted', 'false')
			}).fail(function() {
				$button.attr('disabled', false);
			});
		} else {
			$.ajax('https://api.misskey.xyz/post/repost', {
				type: 'post',
				data: { 'post_id': $post.attr('data-id') },
				dataType: 'json',
				xhrFields: { withCredentials: true }
			}).done(function() {
				$button.attr('disabled', false);
				$post.attr('data-is-reposted', 'true')
			}).fail(function() {
				$button.attr('disabled', false);
			});
		}
	});

	$post.click(function(event) {
		if ($(event.target).is('input') ||
		$(event.target).is('textarea') ||
		$(event.target).is('button') ||
		$(event.target).is('i') ||
		$(event.target).is('time') ||
		$(event.target).is('a')) return;
		if (document.getSelection().toString() == '') {
			if ($(this).children('footer').css('display') === 'none') {
				$('.timeline > .statuses > .status.post > .moreTalk > i').each(function() {
					$(this).show(200);
				});
				$('.timeline > .statuses > .status.post > .moreTalk > .talk').each(function() {
					$(this).hide(200);
				});
				$('.timeline > .statuses > .status.post > footer').each(function() {
					$(this).hide(200);
				});
				$(this).children('.moreTalk').children('i').hide(200);
				$(this).children('.moreTalk').children('.talk').show(200);
				$(this).children('footer').show(200);
				var text = $(this).find('footer .replyForm textarea').val();
				$(this).find('footer .replyForm textarea').val('');
				$(this).find('footer .replyForm textarea').focus().val(text);
			} else {
				$(this).children('.moreTalk').children('i').show(200);
				$(this).children('.moreTalk').children('.talk').hide(200);
				$(this).children('footer').hide(200);
			}
		}
	});

	/*
	$post.dblclick(function (event) {
	if ($(event.target).is('input') || $(event.target).is('textarea')) return;
	window.open('https://misskey.xyz/' + $(this).attr('data-user-screen_name') + '/post/' + $(this).attr('data-id'));
	});
	*/

}

$(function() {
	$('.timeline .post').each(function() {
		TIMELINE.setEventPost($(this));
	});
});