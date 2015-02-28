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