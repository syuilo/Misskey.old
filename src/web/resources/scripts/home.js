$(function() {
	try {
		Notification.requestPermission();
	} catch (e) {

	}

	socket = io.connect('https://api.misskey.xyz:1207/streaming/home', { port: 1207 });

	socket.on('connected', function() {
		console.log('Connected');
	});

	socket.on('disconnect', function(client) {
	});

	socket.on('post', function(post) {
		console.log('post', post);
		new Audio('/resources/sounds/pop.mp3').play();
		var $post = TIMELINE.generatePostElement(post, conf).hide()
		TIMELINE.setEventPost($post);
		$post.prependTo($('#timeline .timeline > .posts')).show(200);
	});

	socket.on('reply', function(post) {
		console.log('reply', post);
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

		$.ajax($form.attr('action'), {
			type: $form.attr('method'),
			processData: false,
			contentType: false,
			data: new FormData($form[0]),
			dataType: 'json',
			xhrFields: {
				withCredentials: true
			}
		}).done(function(data) {
			$form[0].reset();
			$form.find('.imageAttacher img').remove();
			$form.find('.imageAttacher').append($('<p><i class="fa fa-picture-o"></i></p>'));
			$submitButton.attr('disabled', false);
			$submitButton.text('Update');
		}).fail(function(data) {
			$form[0].reset();
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

