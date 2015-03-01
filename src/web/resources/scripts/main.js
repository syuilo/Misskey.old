$.fn.extend({
	viewportOffset: function() {
		$window = $(window);
		p = this.offset();
		return { left: p.left - $window.scrollLeft(), top: p.top - $window.scrollTop() };
	}
});

function escapeHTML(val) {
	return $('<div />').text(val).html();
};

$(function() {
	updateRelativeTimes();

	setInterval(function() {
		updateRelativeTimes();
	}, 100);

	function updateRelativeTimes() {
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
	}
});

function openWindow(id, $content, title, width, height, canPopout, popoutUrl) {
	var canPopout = canPopout === undefined ? false : canPopout;

	var $window = $("\
		<div class=\"ui window\" id=\"" + id + "\">\
			<header>\
				<h1>"+ title + "</h1>\
				<div class=\"buttons\">\
					<button class=\"popout\" title=\"ポップアウト\"><img src=\"/resources/images/window-popout.png\" alt=\"Popout\"></button>\
					<button class=\"close\" title=\"閉じる\"><img src=\"/resources/images/window-close.png\" alt=\"Close\"></button>\
				</div>\
			</header>\
			<div class=\"content\"></div>\
		</div>\
	").css({
		width: width,
		height: height
	});
	$window.find(".content").append($content);
	$("body").prepend($window);

	function top() {
		var z = 0;
		$(".window").each(function() {
			if ($(this).css("z-index") > z)
				z = Number($(this).css("z-index"));
		});
		$window.css("z-index", z + 1);
	}

	function popout() {
		var openedWindow = window.open(popoutUrl, popoutUrl, 'width=' + width + ',height=' + height + ',menubar=no,toolbar=no,location=no,status=no');
		close();
	}

	function close() {
		$window.css({
			"transform": "perspective(512px) rotateX(22.5deg) scale(0.9)",
			"opacity": "0",
			"transition": "all ease-in 0.3s"
		});
		setTimeout(function() {
			$window.remove();
		}, 300);
	}

	$window.ready(function() {
		top();

		/*$window.css({
			"top": ($(window).scrollTop() + (($(window).height() / 2) - ($window.outerHeight() / 2) + ((Math.random() * 128) - 64))) + "px",
			"left": (($(window).width() / 2) - ($window.outerWidth() / 2) + ((Math.random() * 128) - 64)) + "px",
		});*/
		$window.css({
			"bottom": (($(window).height() / 2) - ($window.height() / 2) + ((Math.random() * 128) - 64)) + "px",
			"right": (($(window).width() / 2) - ($window.width() / 2) + ((Math.random() * 128) - 64)) + "px",
		});
		$window.animate({
			"opacity": "1",
			"transform": "scale(1)",
		}, 200);
	});

	$window.find("header > .buttons > .popout").click(function() {
		popout();
	});

	$window.find("header > .buttons > .close").click(function() {
		close();
	});

	$window.mousedown(function() {
		top();
	});

	$window.find("header").mousedown(function(e) {
		if ($(e.target).is('button') ||
		$(e.target).is('img')) return;

		$window.find(".content").css({
			'pointer-events': 'none',
			'user-select': 'none'
		});

		var position = $window.position();

		var clickX = e.clientX;
		var clickY = e.clientY;
		var moveBaseX = clickX - position.left;
		var moveBaseY = clickY - position.top;
		var browserWidth = $(window).width();
		var browserHeight = $(window).height();
		var windowWidth = $window.outerWidth();
		var windowHeight = $window.outerHeight();

		$("html").mousemove(function(me) {
			var moveRight = browserWidth - ((windowWidth + me.clientX) - moveBaseX);
			var moveBottom = browserHeight - ((windowHeight + me.clientY) - moveBaseY);
			if (moveRight < 0) moveRight = 0;
			if (moveBottom < 0) moveBottom = 0;
			if (moveRight + windowWidth > browserWidth) moveRight = browserWidth - windowWidth;
			if (moveBottom + windowHeight > browserHeight) moveBottom = browserHeight - windowHeight;

			$window.css({
				"right": moveRight + "px",
				"bottom": moveBottom + "px",
			});
		});
		$("html").mouseleave(function() {
			$(this).unbind("mouseup mousemove mouseleave");
			endMove();
		});
		$("html").mouseup(function() {
			$(this).unbind("mouseup mousemove mouseleave");
			endMove();
		});
		$("html").bind("dragstart", function(e) {
			$(this).unbind("mouseup mousemove mouseleave");
			endMove();
		});
		$("html").bind("dragend", function(e) {
			$(this).unbind("mouseup mousemove mouseleave");
			endMove();
		});

		function endMove() {
			$window.find(".content").css({
				'pointer-events': 'auto',
				'user-select': 'auto'
			});
		}
	});

	$(window).resize(function() {
		var position = $window.position();
		var browserWidth = $(window).width();
		var browserHeight = $(window).height();
		var windowWidth = $window.outerWidth();
		var windowHeight = $window.outerHeight();

		if (position.left < 0) {
			$window.css({
				"right": (browserWidth - windowWidth) + "px"
			});
		}
		if (position.top < 0) {
			$window.css({
				"bottom": (browserHeight - windowHeight) + "px"
			});
		}
		if (position.left + windowWidth > browserWidth) {
			$window.css({
				"right": "0px"
			});
		}
		if (position.top + windowHeight > browserHeight) {
			$window.css({
				"bottom": "0px"
			});
		}
	});
}

/*!
 * jQuery Cookie Plugin v1.4.1
 * https://github.com/carhartl/jquery-cookie
 *
 * Copyright 2006, 2014 Klaus Hartl
 * Released under the MIT license
 */
(function(factory) {
	if (typeof define === 'function' && define.amd) {
		// AMD
		define(['jquery'], factory);
	} else if (typeof exports === 'object') {
		// CommonJS
		factory(require('jquery'));
	} else {
		// Browser globals
		factory(jQuery);
	}
}(function($) {

	var pluses = /\+/g;

	function encode(s) {
		return config.raw ? s : encodeURIComponent(s);
	}

	function decode(s) {
		return config.raw ? s : decodeURIComponent(s);
	}

	function stringifyCookieValue(value) {
		return encode(config.json ? JSON.stringify(value) : String(value));
	}

	function parseCookieValue(s) {
		if (s.indexOf('"') === 0) {
			// This is a quoted cookie as according to RFC2068, unescape...
			s = s.slice(1, -1).replace(/\\"/g, '"').replace(/\\\\/g, '\\');
		}

		try {
			// Replace server-side written pluses with spaces.
			// If we can't decode the cookie, ignore it, it's unusable.
			// If we can't parse the cookie, ignore it, it's unusable.
			s = decodeURIComponent(s.replace(pluses, ' '));
			return config.json ? JSON.parse(s) : s;
		} catch (e) { }
	}

	function read(s, converter) {
		var value = config.raw ? s : parseCookieValue(s);
		return $.isFunction(converter) ? converter(value) : value;
	}

	var config = $.cookie = function(key, value, options) {

		// Write

		if (arguments.length > 1 && !$.isFunction(value)) {
			options = $.extend({}, config.defaults, options);

			if (typeof options.expires === 'number') {
				var days = options.expires, t = options.expires = new Date();
				t.setTime(+t + days * 864e+5);
			}

			return (document.cookie = [
				encode(key), '=', stringifyCookieValue(value),
				options.expires ? '; expires=' + options.expires.toUTCString() : '', // use expires attribute, max-age is not supported by IE
				options.path ? '; path=' + options.path : '',
				options.domain ? '; domain=' + options.domain : '',
				options.secure ? '; secure' : ''
			].join(''));
		}

		// Read

		var result = key ? undefined : {};

		// To prevent the for loop in the first place assign an empty array
		// in case there are no cookies at all. Also prevents odd result when
		// calling $.cookie().
		var cookies = document.cookie ? document.cookie.split('; ') : [];

		for (var i = 0, l = cookies.length; i < l; i++) {
			var parts = cookies[i].split('=');
			var name = decode(parts.shift());
			var cookie = parts.join('=');

			if (key && key === name) {
				// If second argument (value) is a function it's a converter...
				result = read(cookie, value);
				break;
			}

			// Prevent storing a cookie that we couldn't decode.
			if (!key && (cookie = read(cookie)) !== undefined) {
				result[name] = cookie;
			}
		}

		return result;
	};

	config.defaults = {};

	$.removeCookie = function(key, options) {
		if ($.cookie(key) === undefined) {
			return false;
		}

		// Must not alter options, thus extending a fresh object...
		$.cookie(key, '', $.extend({}, options, { expires: -1 }));
		return !$.cookie(key);
	};

}));