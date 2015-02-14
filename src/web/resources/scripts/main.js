function openWindow($content, title, width, height) {
	var $window = $("\
		<div class=\"ui window\">\
			<header>\
				<h1>"+ title + "</h1>\
				<a href=\"#\" class=\"close\"><img src=\"https://misskey.xyz/resources/images/window-close.png\" alt=\"close\"/></a>\
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

	function close() {
		event.preventDefault();
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
			"top": (($(window).height() / 2) - ($window.outerHeight() / 2) + ((Math.random() * 128) - 64)) + "px",
			"left": (($(window).width() / 2) - ($window.outerWidth() / 2) + ((Math.random() * 128) - 64)) + "px",
		});
		$window.animate({
			"opacity": "1",
			"transform": "scale(1)",
		}, 200);
	});

	$window.find("header > .close").click(function(event) {
		close();
	});

	$window.mousedown(function() {
		top();
	});

	$window.find("header").mousedown(function(e) {
		var position = $window.position();

		var clickX = e.clientX;
		var clickY = e.clientY;
		var moveBaseX = clickX - position.left;
		var moveBaseY = clickY - position.top;

		$("html").mousemove(function(me) {
			$window.css({
				"top": (me.clientY - moveBaseY) + "px",
				"left": (me.clientX - moveBaseX) + "px",
			});
		});
		$("html").mouseleave(function() {
			$(this).unbind("mouseup mousemove mouseleave");
		});
		$("html").mouseup(function() {
			$(this).unbind("mouseup mousemove mouseleave");
		});
	});
}