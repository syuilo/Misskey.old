$.fn.isVisible = function() {
	return $.expr.filters.visible(this[0]);
};

//ウィンドウのリサイズ時
$(window).on('load resize', function() {
	$('main').width( $(window).width() - $('nav').width() );
});

$(function() {
	$('li p').hide();

	$('nav ul li h1').click(function () {
		if($(this).parent().children('p').isVisible() == true) {
			$(this).parent().children('p').hide(250);
		} else {
			$(this).parent().children('p').show(250);
		}
	});
});