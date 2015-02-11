var SYUILOUI = {};

SYUILOUI.Tab = function($tabList) {
	var $tabContents = [];

	$tabList.find('li').each(function(i, elem) {
		var $tabListItem = $(elem);
		var id = $tabListItem.find('a').attr('href');
		$tabContents.push($(id));
		$tabListItem.addClass('unactive');

		$tabListItem.click(function() {
			var num = $tabList.find('li').index(this);
			$tabList.find('li').removeClass('active').addClass('unactive');
			$(this).removeClass('unactive').addClass('active');

			$.each($tabContents, function() {
				$(this).css("display", "none");
			});

			$tabContents[num].css("display", "block");

			return false;
		});
	});

	$tabContents.each(function(i, elem) {
		var $tabContent = $(elem);
		$tabContent.css("display", "none");
	});

	$tabList.find('li:eq(0)').removeClass('unactive').addClass('active');
	$tabContent[0].css("display", "block");
}
