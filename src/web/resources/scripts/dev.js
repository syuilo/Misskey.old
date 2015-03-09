$.fn.isVisible = function() {
	return $.expr.filters.visible(this[0]);
};

function showContents(targetUrl, methodType) {
	if(methodType == 'GET') {
		dispLoading();
		$.ajax({
			url: targetUrl,
			type: 'GET',
			dataType: 'html',
		})
		.done(function(data) {
			$("main").html($(data).children("main").html());
		})
		.fail(function(data) {
			//失敗時
		})
		.always(function(data) {
			removeLoading();
		});
	}else{
		console.log("not implement.");
	}
}

function dispLoading(message) {
	var loadingMessage = message != '' ? '<div id="loading-text">' + message + '</div>' : '';
	if($('#loading').size() == 0) {
		$('main').html('<div id="loading"><i id="loading-image"></i>' + loadingMessage + '</div>');
		$('#loading').hide();
		$('#loading').fadeIn(500);
	}
}

function removeLoading() {
	$('#loading').fadeOut(
		500,
		function() {
			$('#loading').remove();
		});
}

$(function() {
	$('#contents > nav > ul > li > ul').hide();

	$('#contents nav ul li h1').click(function () {
		if($(this).parent().children('ul').isVisible() == true) {
			$(this).parent().children('ul').hide(250);
		} else {
			$(this).parent().children('ul').show(250);
		}
	});

	$('#myapp ul li').click(function () {
		if($(this).children().prop('nodeType') != 1) {
			var idName = $(this).attr('id');
			if(idName == 'myapp-new') {
				showContents('https://misskey.xyz/dev/myapp-new', 'GET');
			} else {
				showContents('https://misskey.xyz/dev/myapp?q=' + idName, 'GET');
			}
		}
	});

	$('#restapi ul li , #streamingapi ul li').click(function () {
		if($(this).children().prop("nodeType") != 1) {
			var idName = $(this).attr("id");
			showContents('https://misskey.xyz/dev/reference?q=' + idName, 'GET');
		}
	});

	$('#usertheme ul li').click(function () {
		if($(this).children().prop("nodeType") != 1) {
			var idName = $(this).attr("id");
			if(idName == "usertheme-new") {
				showContents('https://misskey.xyz/dev/usertheme-new', 'GET');
			} else {
				showContents('https://misskey.xyz/dev/usertheme?q=' + idName, 'GET');
			}
		}
	});
});