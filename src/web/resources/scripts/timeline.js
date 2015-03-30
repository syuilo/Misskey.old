var TIMELINE = {};

TIMELINE.setEventPost = function($post) {
	$post.children('article').children('a').click(function() {
		var windowId = 'misskey-window-talk-' + $post.attr('data-user-id');
		var url = $post.children('article').children('a').attr('href');
		var $content = $("<iframe>").attr({ src: url, seamless: true });
		openWindow(windowId, $content, '<i class="fa fa-comments"></i>' + $post.children('article').children('header').children('h2').children('a').text(), 300, 450, true, url);
		return false;
	});

	$post.find('.reply-form').submit(function(event) {
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

	$post.find('.image-attacher input[name=image]').change(function() {
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

	$post.find('article > footer > .actions > .favorite > .favorite-button').click(function() {
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

	$post.find('article > footer > .actions > .repost > .repost-button').click(function() {
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
				$('.timeline > .statuses > .status > .status.article > .more-talk > i').each(function() {
					$(this).show(200);
				});
				$('.timeline > .statuses > .status > .status.article > .more-talk > .talk').each(function() {
					$(this).hide(200);
				});
				$('.timeline > .statuses > .status > .status.article > footer').each(function() {
					$(this).hide(200);
				});
				$(this).children('.more-talk').children('i').hide(200);
				$(this).children('.more-talk').children('.talk').show(200);
				$(this).children('footer').show(200);
				var text = $(this).find('footer .reply-form textarea').val();
				$(this).find('footer .reply-form textarea').val('');
				$(this).find('footer .reply-form textarea').focus().val(text);
			} else {
				$(this).children('.more-talk').children('i').show(200);
				$(this).children('.more-talk').children('.talk').hide(200);
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
	$('.timeline .status').each(function() {
		TIMELINE.setEventPost($(this));
	});
});