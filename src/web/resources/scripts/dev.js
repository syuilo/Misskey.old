$.fn.isVisible = function() {
	return $.expr.filters.visible(this[0]);
};

$(function() {
	$('#contents nav ul li').hide();

	$('#contents nav ul li h1').click(function () {
		if($(this).parent().children('p').isVisible() == true) {
			$(this).parent().children('p').hide(250);
		} else {
			$(this).parent().children('p').show(250);
		}
	});

	$('#myApp ul li').click(function () {
		$.ajax({
			url: 'https://misskey.xyz/dev/myapp',
			type: 'GET',
			dataType: 'html',
		})
		.done(function(data) {
			$(data).find('#contents main').get(0).html(data);
		})
		.fail(function(data) {
			//失敗時
		});
	}

	$('#restApi ul li').click(function () {
		var idName = $(this).attr("id");
		$.ajax({
			url: 'https://misskey.xyz/dev/reference',
			type: 'GET',
			dataType: 'html',
		})
		.done(function(data) {
			$(data).find('#contents main').get(0).html(data);
		})
		.fail(function(data) {
			//失敗時
		});
	}

	$('#userTheme ul li').click(function () {
		var idName = $(this).attr("id");
		$.ajax({
			url: 'https://misskey.xyz/dev/usertheme',
			type: 'GET',
			dataType: 'html',
		})
		.done(function(data) {
			$(data).find('#contents main').get(0).html(data);
		})
		.fail(function(data) {
			//失敗時
		});
	}
});