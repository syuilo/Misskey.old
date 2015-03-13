$(function() {
	try {
		Notification.requestPermission();
	} catch (e) {

	}

	// オートセーブがあるなら復元
	if ($.cookie('post-autosave')) {
		$('#postForm textarea').val($.cookie('post-autosave'));
	}

	socket = io.connect('https://api.misskey.xyz:1207/streaming/home', { port: 1207 });

	socket.on('connected', function() {
		console.log('Connected');
	});

	socket.on('disconnect', function(client) {
	});

	socket.on('post', function(post) {
		console.log('post', post);
		var currentPath = location.pathname;
		currentPath = currentPath.indexOf('/') == 0 ? currentPath : '/' + currentPath;
		if (currentPath != "/i/mention") {
			new Audio('/resources/sounds/pop.mp3').play();
			var $post = TIMELINE.generatePostElement(post, conf).hide();
			TIMELINE.setEventPost($post);
			$post.prependTo($('#timeline .timeline > .statuses')).show(200);
		}
	});

	socket.on('repost', function(post) {
		console.log('repost', post);
		new Audio('/resources/sounds/pop.mp3').play();
		var $post = TIMELINE.generatePostElement(post, conf).hide();
		TIMELINE.setEventPost($post);
		$post.prependTo($('#timeline .timeline > .statuses')).show(200);
	});

	socket.on('reply', function(post) {
		console.log('reply', post);
		var currentPath = location.pathname;
		currentPath = currentPath.indexOf('/') == 0 ? currentPath : '/' + currentPath;
		if (currentPath == "/i/mention") {
			new Audio('/resources/sounds/pop.mp3').play();
			var $post = TIMELINE.generatePostElement(post, conf).hide();
			TIMELINE.setEventPost($post);
			$post.prependTo($('#timeline .timeline > .statuses')).show(200);
			var n = new Notification(post.user.name, {
				body: post.text,
				icon: conf.url + '/img/icon/' + post.user.screenName
			});
			n.onshow = function() {
				setTimeout(function() {
					n.close();
				}, 10000);
			};
			n.onclick = function() {
				window.open(conf.url + '/' + post.user.screenName + '/post/' + post.id);
			};
		}
	});

	socket.on('talkMessage', function(message) {
		console.log('talkMessage', message);
		var windowId = 'misskey-window-talk-' + message.user.id;
		if ($('#' + windowId)[0]) {
			return;
		}
		var n = new Notification(message.user.name, {
			body: message.text,
			icon: conf.url + '/img/icon/' + message.user.screenName
		});
		n.onshow = function() {
			setTimeout(function() {
				n.close();
			}, 10000);
		};
		n.onclick = function() {
			var url = 'https://misskey.xyz/' + message.user.screenName + '/talk?noheader=true';
			var $content = $("<iframe>").attr({ src: url, seamless: true });
			openWindow(windowId, $content, '<i class="fa fa-comments"></i>' + escapeHTML(message.user.name), 300, 450, true, url);
		};
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
	
	$('#postForm').keydown(function(event) {
		if (event.charCode == 13 && event.ctrlKey) {
			event.preventDefault();
			post();
		}
	});	
	
	$('#postForm').submit(function(event) {
		event.preventDefault();

		post();
	});
	
	function post()
	{
		var form = $('#postForm');
		var $submitButton = $form.find('[type=submit]');

		$submitButton.attr('disabled', true);
		$submitButton.text('Updating...');

		$.ajax('https://api.misskey.xyz/post/create', {
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
			$.removeCookie('post-autosave');
		}).fail(function(data) {
			$form[0].reset();
			$form.find('textarea').focus();
			/*alert('error');*/
			$submitButton.attr('disabled', false);
			$submitButton.text('Update');
		});
	}

	$('#postForm textarea').bind('input', function() {
		var text = $('#postForm textarea').val();

		// オートセーブ
		$.cookie('post-autosave', text, { path: '/', expires: 365 });
	});

	$('#timeline .loadMore').click(function() {
		$button = $(this);
		$button.attr('disabled', true);
		$button.text('Loading...');
		$.ajax('https://api.misskey.xyz/post/timeline', {
			type: 'get',
			data: { max_id: $('#timeline .timeline .statuses > .status:last-child').attr('data-id') },
			dataType: 'json',
			xhrFields: { withCredentials: true }
		}).done(function(data) {
			$button.attr('disabled', false);
			$button.text('Read more!');
			data.forEach(function(post) {
				var $post = TIMELINE.generatePostElement(post, conf).hide();
				TIMELINE.setEventPost($post);
				$post.appendTo($('#timeline .timeline > .statuses')).show(200);
			});
		}).fail(function(data) {
			$button.attr('disabled', false);
			$button.text('Failed...');
		});
	});
});
