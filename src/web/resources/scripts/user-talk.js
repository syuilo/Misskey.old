var TALKSTREAM = {};

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
					data: { 'message-id': id, text: text },
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

		$message.find('.delete-button').click(function() {
			$button = $(this);
			$button.attr('disabled', true);
			$.ajax('https://api.misskey.xyz/talk/delete', {
				type: 'delete',
				data: { 'message-id': id },
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
	var meId = $("html").attr("data-me-id");
	var meSn = $("html").attr("data-me-screen-name");
	var otherpartyId = $("html").attr("data-otherparty-id");
	var otherpartySn = $("html").attr("data-otherparty-screen-name");

	// オートセーブがあるなら復元
	if ($.cookie('talk-autosave-' + otherpartyId)) {
		$('#post-form textarea').val($.cookie('talk-autosave-' + otherpartyId));
	}

	$("body").css("margin-bottom", $("#post-form-container").outerHeight() + "px");
	scroll(0, $('html').outerHeight())

	socket = io.connect('https://api.misskey.xyz:1207/streaming/talk', { port: 1207 });

	socket.on('connected', function() {
		console.log('Connected');
		socket.json.emit('init', {
			'otherparty-id': otherpartyId
		});
	});

	socket.on('inited', function() {
		console.log('Inited');
		socket.emit('alive');
		$('.messages .message.otherparty').each(function() {
			socket.emit('read', $(this).attr('data-id'));
		});
	});

	socket.on('disconnect', function(client) {
		console.log('Disconnected');
	});

	socket.on('otherparty-enter-the-talk', function(client) {
		console.log('相手が入室しました');
	});

	socket.on('otherparty-left-the-talk', function(client) {
		console.log('相手が退室しました');
	});

	socket.on('otherparty-message', function(message) {
		console.log('otherparty-message', message);
		socket.emit('read', message.id);
		new Audio('/resources/sounds/talk-message.mp3').play();
		if ($('#otherparty-status #otherparty-typing')[0]) {
			$('#otherparty-status #otherparty-typing').remove();
		}
		var $message = $('<li class="message">').append($(message)).hide();
		TIMELINE.setEvent($message.children('.message'));
		$status.prependTo($('#stream .messages')).show(200);
		$.ajax('https://api.misskey.xyz/talk/read', {
			type: 'post',
			data: { 'message-id': message.id },
			dataType: 'json',
			xhrFields: { withCredentials: true }
		}).done(function(data) {
		}).fail(function(data) {
		});
	});

	socket.on('me-message', function(message) {
		console.log('me-message', message);
		new Audio('/resources/sounds/talk-message.mp3').play();
		var $message = $('<li class="message">').append($(message)).hide();
		TIMELINE.setEvent($message.children('.message'));
		$status.prependTo($('#stream .messages')).show(200);
	});

	socket.on('otherparty-message-update', function(message) {
		console.log('otherparty-message-update', message);
		var $message = $('#stream > .messages').find('.message[data-id=' + message.id + ']');
		if ($message != null) {
			$message.find('.text').text(message.text);
		}
	});

	socket.on('me-message-update', function(message) {
		console.log('me-message-update', message);
		var $message = $('#stream > .messages').find('.message[data-id=' + message.id + ']');
		if ($message != null) {
			$message.find('.text').text(message.text);
		}
	});

	socket.on('otherparty-message-delete', function(id) {
		console.log('otherparty-message-delete', id);
		var $message = $('#stream > .messages').find('.message[data-id=' + id + ']');
		if ($message != null) {
			$message.find('.content').empty();
			$message.find('.content').append('<p class="is-deleted">このメッセージは削除されました</p>');
		}
	});

	socket.on('me-message-delete', function(id) {
		console.log('otherparty-message-delete', id);
		var $message = $('#stream > .messages').find('.message[data-id=' + id + ']');
		if ($message != null) {
			$message.find('.content').empty();
			$message.find('.content').append('<p class="is-deleted">このメッセージは削除されました</p>');
		}
	});

	socket.on('read', function(id) {
		console.log('read', id);
		var $message = $('#stream > .messages').find('.message[data-id=' + id + ']');
		if ($message != null) {
			if ($message.attr('data-is-readed') == 'false') {
				$message.attr('data-is-readed', 'true');
				$message.find('.content-container').prepend($('<p class="readed">').text('既読'));
			}
		}
	});

	socket.on('alive', function() {
		console.log('alive');
		var $status = $('<img src="/img/icon/' + otherpartySn + '" alt="icon" id="alive">');
		if ($('#otherparty-status #alive')[0]) {
			$('#otherparty-status #alive').remove();
		} else {
			$status.addClass('opening');
		}
		$('#otherparty-status').prepend($status);
		scroll(0, $('html').outerHeight());
		setTimeout(function() {
			$status.addClass('normal');
			$status.removeClass('opening');
		}, 500);
		setTimeout(function() {
			$status.addClass('closing');
			setTimeout(function() {
				$status.remove();
			}, 1000);
		}, 3000);
	});

	socket.on('type', function(type) {
		console.log('type', type);
		if ($('#otherparty-status #otherparty-typing')[0]) {
			$('#otherparty-status #otherparty-typing').remove();
		}
		if (type == '') {
			return;
		}
		var $typing = $('<p id="otherparty-typing">' + escapeHTML(type) + '</p>');
		$typing.appendTo($('#otherparty-status')).animate({
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

	$('#post-form textarea').bind('input', function() {
		var text = $('#post-form textarea').val();

		// オートセーブ
		$.cookie('talk-autosave-' + otherpartyId, text, { expires: 365 });

		socket.emit('type', text);
	});

	$('#post-form').find('.image-attacher input[name=image]').change(function() {
		var $input = $(this);
		var file = $(this).prop('files')[0];
		if (!file.type.match('image.*')) return;
		var reader = new FileReader();
		reader.onload = function() {
			var $img = $('<img>').attr('src', reader.result);
			$input.parent('.image-attacher').find('p, img').remove();
			$input.parent('.image-attacher').append($img);
		};
		reader.readAsDataURL(file);
	});

	$('#post-form').submit(function(event) {
		event.preventDefault();
		var $form = $(this);
		var $submitButton = $form.find('[type=submit]');

		$submitButton.attr('disabled', true);

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
			$form.find('.image-attacher').find('p, img').remove();
			$form.find('.image-attacher').append($('<p><i class="fa fa-picture-o"></i></p>'));
			$submitButton.attr('disabled', false);
			$.removeCookie('talk-autosave-' + otherpartyId);
		}).fail(function(data) {
			$form[0].reset();
			$form.find('textarea').focus();
			/*alert('error');*/
			$submitButton.attr('disabled', false);
		});
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
		}, 210);
	}
});

$(window).load(function() {
	$("body").css("margin-bottom", $("#post-form-container").outerHeight() + "px");
	scroll(0, document.body.clientHeight)
});

$(window).resize(function() {
	$("body").css("margin-bottom", $("#post-form-container").outerHeight() + "px");
});

$(function() {
	$('.messages .message.me').each(function() {
		TALKSTREAM.setEvent($(this));
	});
});