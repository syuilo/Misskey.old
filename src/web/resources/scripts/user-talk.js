$(function() {
	socket = io.connect('https://api.misskey.xyz:1207/streaming/talk', { port: 1207 });

	socket.on('connected', function() {
		console.log('Connected');
		socket.json.emit('init', {
			'otherparty_id': $("html").attr("data-otherpartyId")
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
		var $message = generateMessageElement(message, conf).hide();
		$message.appendTo($('#stream > .messages')).show(200);
	});

	socket.on('meMessage', function(message) {
		console.log('meMessage', message);
		var $message = generateMessageElement(message, conf).hide();
		$message.appendTo($('#stream > .messages')).show(200);
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

	setInterval(function() {
		var now = new Date();
		$('time').each(function() {
			function pad2(n) { return n < 10 ? '0' + n : n }
			var date = new Date($(this).attr('datetime'));
			var ago = ~~((now - date) / 1000);
			var timeText =
				ago >= 31536000 ? ~~(ago / 31536000) + "年前" :
				ago >= 2592000 ? ~~(ago / 2592000) + "ヶ月前" :
				ago >= 604800 ? ~~(ago / 604800) + "週間前" :
				ago >= 86400 ? ~~(ago / 86400) + "日前" :
				ago >= 3600 ? ~~(ago / 3600) + "時間前" :
				ago >= 60 ? ~~(ago / 60) + "分前" :
				ago >= 5 ? ~~(ago % 60) + "秒前" :
				ago < 5 ? 'いま' : "";
			$(this).text(timeText);
		});
	}, 1000);
});


function generateMessageElement(message) {
	return $('<li>')
	.attr({
		class: 'message ' + (message.userId == $("html").attr("data-meId") ? 'me' : 'otherparty'),
		title: message.createdAt + '&#x0A;via ' + message.app.name,
		'data-id': message.id,
		'data-userId': message.userId,
		'data-userComment': message.user.comment,
		'data-userColor': message.user.color
	})
	.append(generateArticle());

	function generateArticle() {
		return $('<article>')
		.append(generateIcon())
		.append(generateContent());

		function generateIcon() {
			return $('<a>')
			.attr('href', conf.url + '/' + message.user.screenName)
			.append(
			$('<img class="icon" alt="icon">')
			.attr('src', conf.url + '/img/icon/' + message.user.screenName)
			);
		}

		function generateContent() {
			return $('<div class="content">')
			.append($('<p class="text">').html(parseText(message.text)))
			.append(message.isImageAttached ? generateImage() : null)

			function generateImage() {
				return $('<img alt="image" class="image">')
				.attr('src', conf.url + '/img/post/' + message.id);
			}
		}
	}

	function parseText(text) {
		text = escapeHtml(text);
		text = parseURL(text);
		text = parseReply(text);
		text = parseBold(text);
		text = parseSmall(text);
		text = parseNewLine(text);
		return text;

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