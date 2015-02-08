/// <reference path="../../../typings/bundle.d.ts" />

function generatePost(post: any, conf: any): JQuery {
	return $('<li class="post">')
		.attr({
		title: `${post.createdAt}&#x0A;via ${post.app.name}`,
		'data-id': post.id,
		'data-userId': post.userId
	})
		.append(post.isReply ? generateReplyTo() : null)
		.append(generateArticle())
		.append(generateFooter());

	function generateReplyTo(): JQuery {
		return $('<div class="replyTo">')
			.append(
			$('<p class="text">')
				.text(parseText(post.reply.text)));
	}

	function generateArticle(): JQuery {
		return $('<article>')
			.append(generateIcon())
			.append(generateHeader())
			.append($('<p class="text">').text(parseText(post.text)))
			.append(post.isImageAttached ? generateImage() : null);

		function generateIcon(): JQuery {
			return $('<a>')
				.attr('href', `${conf.url}/${post.user.screenName}`)
				.append(
				$('<img class="icon" alt="icon">')
					.attr('src', `${conf.url}/img/icon/${post.user.screenName}`)
				);
		}

		function generateHeader(): JQuery {
			return generateHeader()
				.append(generateScreenName())
				.append(generateTime());

			function generateHeader() {
				return $('<header>').prepend($('<h2>').prepend(generateName()));
			}

			function generateName() {
				return $('<a>')
					.attr('href', `${conf.url}/${post.user.screenName}`)
					.text(escapeHtml(post.user.name));
			}

			function generateScreenName() {
				return $('<span class="screenName">')
					.text(post.user.screenName);
			}

			function generateTime() {
				return $('<time>')
					.text(post.createdAt);
			}
		}

		function generateImage(): JQuery {
			return $('<img alt="image">')
				.attr('src', `${conf.url}/img/post/${post.id}`);
		}
	}

	function generateFooter(): JQuery {
		return $('<footer>')
			.append(generateForm());

		function generateForm(): JQuery {
			return $('<form class="replyForm">')
				.append(generateTextArea())
				.append(generateInReplyToPostId())
				.append(generateSubmitButton())
				.append(generateImageAttacher());

			function generateTextArea() {
				return $('<textarea name="text">');
			}

			function generateInReplyToPostId(): JQuery {
				return $('<input name="in_reply_to_post_id" type="hidden">')
					.attr('value', post.id);
			}

			function generateSubmitButton(): JQuery {
				return $('<input type="submit" value="Update">');
			}

			function generateImageAttacher(): JQuery {
				return $('<div class="imageAttacher">')
					.append($('<p>画像を添付</p>'))
					.append($('<input name="image" type="file">'));
			}
		}
	}

	function parseText(text: string): string {
		text = escapeHtml(text);
		text = parseReply(text);
		text = parseURL(text);
		text = parseNewLine(text);
		return text;

		function parseReply(text: string): string {
			return text.replace(/@([a-zA-Z0-9_]+)/g,(_: string, screenName: string) => {
				return `<a href="${conf.url}/${screenName}" target="_blank">@${screenName}</a>`;
			});
		}

		function parseURL(text: string): string {
			return text.replace(/https?:\/\/[-_.!~*a-zA-Z0-9;\/?:\@&=+\$,%#]+/g,(url: string) => {
				return `<a href="${url}" target="_blank">${url}</a>`;
			});
		}

		function parseNewLine(text: string): string {
			return text.replace(/(\r\n|\r|\n)/g, '<br>');
		}
	}

	function escapeHtml(text: string): string {
		return $('<div>').text(text).html();
	}
}
