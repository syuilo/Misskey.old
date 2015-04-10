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
			url: config.apiUrl + '/status/update',
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

	$post.find('article > .article-main > footer .reply-form .tag')
		.tagit({ placeholderText: "タグ", fieldName: "tags[]" });

	$post.find('article > .article-main > .main > .footer > .actions > .favorite > .favorite-button').click(function() {
		var $button = $(this);
		$button.attr('disabled', true);

		if ($post.attr('data-is-favorited') == 'true') {
			$post.attr('data-is-favorited', 'false')
			$.ajax(config.apiUrl + '/status/unfavorite', {
				type: 'delete',
				data: { 'status-id': $post.attr('data-id') },
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
			$.ajax(config.apiUrl + '/status/favorite', {
				type: 'post',
				data: { 'status-id': $post.attr('data-id') },
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

	$post.find('article > .article-main > .main > .footer > .actions > .repost > .repost-button').click(function() {
		var $button = $(this);
		$button.attr('disabled', true);

		if ($post.attr('data-is-reposted') == 'true') {
			$.ajax(config.apiUrl + '/status/unrepost', {
				type: 'delete',
				data: { 'status-id': $post.attr('data-id') },
				dataType: 'json',
				xhrFields: { withCredentials: true }
			}).done(function() {
				$button.attr('disabled', false);
				$post.attr('data-is-reposted', 'false')
			}).fail(function() {
				$button.attr('disabled', false);
			});
		} else {
			$.ajax(config.apiUrl + '/status/repost', {
				type: 'post',
				data: { 'status-id': $post.attr('data-id') },
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
			if ($(this).find('article > .article-main > footer').css('display') === 'none') {
				$('.timeline > .statuses > .status > .status.article').each(function() {
					$(this).attr('data-display-html-is-active', 'false');
					$(this).removeClass('display-html-active-status-prev');
					$(this).removeClass('display-html-active-status-next');
				});
				$('.timeline > .statuses > .status > .status.article > article > .article-main > .talk > i').each(function() {
					$(this).show(200);
				});
				$('.timeline > .statuses > .status > .status.article > article > .article-main > .talk > .statuses').each(function() {
					$(this).hide(200);
				});
				$('.timeline > .statuses > .status > .status.article > article > .article-main > footer').each(function() {
					$(this).hide(200);
				});
				$(this).attr('data-display-html-is-active', 'true');
				$(this).parent().prev().find('.status.article').addClass('display-html-active-status-prev');
				$(this).parent().next().find('.status.article').addClass('display-html-active-status-next');
				$(this).find('article > .article-main > .talk > i').hide(200);
				$(this).find('article > .article-main > .talk > .statuses').show(200);
				$(this).find('article > .article-main > footer').show(200);
				var text = $(this).find('article > .article-main > footer .reply-form textarea').val();
				$(this).find('article > .article-main > footer .reply-form textarea').val('');
				$(this).find('article > .article-main > footer .reply-form textarea').focus().val(text);
			} else {
				$(this).attr('data-display-html-is-active', 'false');
				$(this).parent().prev().find('.status.article').removeClass('display-html-active-status-prev');
				$(this).parent().next().find('.status.article').removeClass('display-html-active-status-next');
				$(this).find('article > .article-main > .talk > i').show(200);
				$(this).find('article > .article-main > .talk > .statuses').hide(200);
				$(this).find('article > .article-main > footer').hide(200);
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
	$('.timeline .statuses .status .status.article').each(function() {
		TIMELINE.setEventPost($(this));
	});
});
