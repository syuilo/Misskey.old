$.fn.isVisible = function() {
	return $.expr.filters.visible(this[0]);
};

$(function() {
	$('#contents nav ul li ul').hide();

	$('#contents nav ul li h1').click(function () {
		if($(this).parent().children('ul').isVisible() == true) {
			$(this).parent().children('ul').hide(250);
		} else {
			$(this).parent().children('ul').show(250);
		}
	});

	$('#myApp ul li').click(function () {
		if($(this).children().prop("nodeType") != 1) {
			var idName = $(this).attr("id");
			$.ajax({
				url: 'https://misskey.xyz/dev/myapp?q=' + idName,
				type: 'GET',
				dataType: 'html',
			})
			.done(function(data) {
				$("main").html($(data).html());
			})
			.fail(function(data) {
				//失敗時
			});
		}
	});

	$('#restApi ul li').click(function () {
		if($(this).children().prop("nodeType") != 1) {
			var idName = $(this).attr("id");
			$.ajax({
				url: 'https://misskey.xyz/dev/reference?q=' + idName,
				type: 'GET',
				dataType: 'html',
			})
			.done(function(data) {
				$("main").html($(data).children("main").html());
			})
			.fail(function(data) {
				//失敗時
			});
		}
	});

	$('#userTheme ul li').click(function () {
		if($(this).children().prop("nodeType") != 1) {
			var idName = $(this).attr("id");
			$.ajax({
				url: 'https://misskey.xyz/dev/usertheme?q=' + idName,
				type: 'GET',
				dataType: 'html',
			})
			.done(function(data) {
				$("main").html($(data).html());
			})
			.fail(function(data) {
				//失敗時
			});
		}
	});
});