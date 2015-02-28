var TALKSTREAM = {};

TALKSTREAM.generateMessageElement = function(message) {
	return $('<li>')
		.attr({
			class: 'message ' + (message.userId == $("html").attr("data-me-id") ? 'me' : 'otherparty'),
			title: message.createdAt + '&#x0A;via ' + message.app.name,
			'data-id': message.id,
			'data-user-id': message.userId,
			'data-user-color': message.user.color
		})
		.append(generateArticle());

	function generateArticle() {
		return $('<article>')
		.append(generateIcon())
		.append(generateContentContainer());

		function generateContentContainer() {
			return $('<div class="contentContainer">')
			.append(message.isReaded ? generateReadStatus() : null)
			.append(message.userId == $("html").attr("data-me-id") ? generateDeleteButton() : null)
			.append(generateContent())
			.append(generateTime());

			function generateReadStatus() {
				return $('<p class="readed">').text('既読');
			}

			function generateDeleteButton() {
				return $('<button class="deleteButton" role="button" title="メッセージを削除">')
				.append($('<img src="/resources/images/destroy.png" alt="Delete">'));
			}

			function generateContent() {
				return $('<div class="content">')
				.append($('<p class="text">').html(parseText(message.text)))
				.append(message.isImageAttached ? generateImage() : null)

				function generateImage() {
					return $('<img alt="image" class="image">')
					.attr('src', conf.url + '/img/talk-message/' + message.id);
				}
			}

			function generateTime() {
				return $('<time>')
				.attr('datetime', message.createdAt)
				.html(message.createdAt);
			}
		}

		function generateIcon() {
			return $('<a class="iconAnchor">')
			.attr('href', conf.url + '/' + message.user.screenName)
			.attr('title', message.user.comment)
			.append(
			$('<img class="icon" alt="icon">')
			.attr('src', conf.url + '/img/icon/' + message.user.screenName)
			);
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

TALKSTREAM.setEvent = function($message) {
	var id = $message.attr('data-id');
	var userId = $message.attr('data-user-id');

	if (userId == $("html").attr("data-me-id")) {
		$message.find('.content').dblclick(function() {
			var $text = $message.find('.text');
			var text = $text.text();
			var $textarea = $('<textarea class="text">').text(text);
			$textarea.css({
				width: ($text.outerWidth() + 1) + 'px',
				height: ($text.outerHeight() + 1) + 'px'
			});
			$text.replaceWith($textarea);
			$textarea.focus();
			$textarea.change(function() {
				var text = $(this).val();
				var $textp = $('<p class="text">').text(text);
				$textarea.replaceWith($textp);
				$.ajax('https://api.misskey.xyz/talk/fix', {
					type: 'put',
					data: { message_id: id, text: text },
					dataType: 'json',
					xhrFields: { withCredentials: true }
				}).done(function(data) {
				}).fail(function(data) {
				});
			});
			$textarea.blur(function() {
				var $textp = $('<p class="text">').text(text);
				$textarea.replaceWith($textp);
			});
		});

		$message.find('.deleteButton').click(function() {
			$button = $(this);
			$button.attr('disabled', true);
			$.ajax('https://api.misskey.xyz/talk/delete', {
				type: 'delete',
				data: { message_id: id },
				dataType: 'json',
				xhrFields: { withCredentials: true }
			}).done(function(data) {
				$message.attr('data-is-deleted', 'true');
				$button.remove();
			}).fail(function(data) {
				$button.attr('disabled', false);
			});
		});
	}
}

$(function() {
	$("body").css("margin-bottom", $("#postFormContainer").outerHeight() + "px");
	scroll(0, $('html').outerHeight())

	socket = io.connect('https://api.misskey.xyz:1207/streaming/talk', { port: 1207 });

	socket.on('connected', function() {
		console.log('Connected');
		socket.json.emit('init', {
			'otherparty_id': $("html").attr("data-otherparty-id")
		});
	});

	socket.on('inited', function() {
		console.log('Inited');
		socket.emit('alive');
		$('.messages .message.otherParty').each(function() {
			socket.emit('read', $(this).attr('data-id'));
		});
	});

	socket.on('disconnect', function(client) {
		console.log('Disconnected');
	});

	socket.on('otherpartyEnterTheTalk', function(client) {
		console.log('相手が入室しました');
	});

	socket.on('otherpartyLeftTheTalk', function(client) {
		console.log('相手が退室しました');
	});

	socket.on('otherpartyMessage', function(message) {
		console.log('otherpartyMessage', message);
		new Audio('/resources/sounds/talk-message.mp3').play();
		if ($('#otherpartyStatus #otherpartyTyping')[0]) {
			$('#otherpartyStatus #otherpartyTyping').remove();
		}
		appendMessage(message);
		$.ajax('https://api.misskey.xyz/talk/read', {
			type: 'post',
			data: { message_id: message.id },
			dataType: 'json',
			xhrFields: { withCredentials: true }
		}).done(function(data) {
		}).fail(function(data) {
		});
	});

	socket.on('meMessage', function(message) {
		console.log('meMessage', message);
		new Audio('/resources/sounds/talk-message.mp3').play();
		appendMessage(message);
	});

	socket.on('otherpartyMessageUpdate', function(message) {
		console.log('otherpartyMessageUpdate', message);
		var $message = $('#stream > .messages').find('.message[data-id=' + message.id + ']');
		if ($message != null) {
			$message.find('.text').text(message.text);
		}
	});

	socket.on('meMessageUpdate', function(message) {
		console.log('meMessageUpdate', message);
		var $message = $('#stream > .messages').find('.message[data-id=' + message.id + ']');
		if ($message != null) {
			$message.find('.text').text(message.text);
		}
	});

	socket.on('otherpartyMessageDelete', function(id) {
		console.log('otherpartyMessageDelete', id);
		var $message = $('#stream > .messages').find('.message[data-id=' + id + ']');
		if ($message != null) {
			$message.find('.content').empty();
			$message.find('.content').append('<p class="isDeleted">このメッセージは削除されました</p>');
		}
	});

	socket.on('meMessageDelete', function(id) {
		console.log('otherpartyMessageDelete', id);
		var $message = $('#stream > .messages').find('.message[data-id=' + id + ']');
		if ($message != null) {
			$message.find('.content').empty();
			$message.find('.content').append('<p class="isDeleted">このメッセージは削除されました</p>');
		}
	});

	socket.on('read', function(id) {
		console.log('read', id);
		var $message = $('#stream > .messages').find('.message[data-id=' + id + ']');
		if ($message != null) {
			$message.find('.contentContainer').prepend($('<p class="readed">').text('既読'));
		}
	});

	socket.on('alive', function() {
		console.log('alive');
		if ($('#otherpartyStatus #alive')[0]) {
			$('#otherpartyStatus #alive').remove();
		}
		var $status = $('<img src="/img/icon/' + $("html").attr("data-otherparty-id") + '" alt="icon" id="alive">');
		$('#otherpartyStatus').prepend($status);
		scroll(0, $('html').outerHeight());
		setTimeout(function() {
			$status.addClass('normal');
		}, 500);
		setTimeout(function() {
			$status.remove();
		}, 3000);
	});

	socket.on('type', function(type) {
		console.log('type', type);
		if ($('#otherpartyStatus #otherpartyTyping')[0]) {
			$('#otherpartyStatus #otherpartyTyping').remove();
		}
		if (type == '') {
			return;
		}
		var $typing = $('<p id="otherpartyTyping">' + escapeHTML(type) + '</p>');
		$typing.appendTo($('#otherpartyStatus')).animate({
			opacity: 0
		}, 5000);
		scroll(0, $('html').outerHeight());
		setTimeout(function() {
			$typing.remove();
		}, 5000);
	});

	setInterval(function() {
		socket.emit('alive');
	}, 2000);

	$('#postForm textarea').bind('input', function() {
		socket.emit('type', $('#postForm textarea').val());
	});

	$('#postForm').find('.imageAttacher input[name=image]').change(function() {
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

	$('#postForm').submit(function(event) {
		event.preventDefault();
		var $form = $(this);
		var $submitButton = $form.find('[type=submit]');

		$submitButton.attr('disabled', true);
		$submitButton.text('Updating...');

		$.ajax('https://api.misskey.xyz/talk/say', {
			type: 'post',
			processData: false,
			contentType: false,
			data: new FormData($form[0]),
			dataType: 'json',
			xhrFields: {
				withCredentials: true
			}
		}).done(function(data) {
			$form[0].reset();
			$form.find('textarea').focus();
			$form.find('.imageAttacher').find('p, img').remove();
			$form.find('.imageAttacher').append($('<p><i class="fa fa-picture-o"></i></p>'));
			$submitButton.attr('disabled', false);
			$submitButton.text('Update');
		}).fail(function(data) {
			$form[0].reset();
			$form.find('textarea').focus();
			/*alert('error');*/
			$submitButton.attr('disabled', false);
			$submitButton.text('Update');
		});
	});
});

$(window).load(function() {
	$("body").css("margin-bottom", $("#postFormContainer").outerHeight() + "px");
	scroll(0, document.body.clientHeight)
});

$(window).resize(function() {
	$("body").css("margin-bottom", $("#postFormContainer").outerHeight() + "px");
});

function appendMessage(message) {
	var $message = TALKSTREAM.generateMessageElement(message).hide();
	$message.appendTo($('#stream > .messages')).show(200);
	TALKSTREAM.setEvent($message);
	var animateTimer = setInterval(function() {
		scroll(0, $('html').outerHeight());
	}, 1);
	setTimeout(function() {
		clearInterval(animateTimer);
	}, 201);
}

$(function() {
	$('.messages .message.me').each(function() {
		TALKSTREAM.setEvent($(this));
	});
});