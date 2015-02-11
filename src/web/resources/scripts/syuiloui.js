var SYUILOUI = {};

SYUILOUI.Tab = function($tabList) {
	var $tabContents = [];

	$tabList.each(function(i, elem) {
		var $tabListItem = $(elem);
		var id = $tabListItem.find('a').attr('href');
		$tabContents.push($(id));
		$tabListItem.addClass('unactive');

		$tabListItem.click(function() {
			var num = $tabList.find('li').index(this);
			$tabList.find('li').removeClass('active');
			$(this).addClass('active');

			$tabContents.each(function() {
				$(this).css("display", "none");
			});

			$tabContents[num].css("display", "block");
		});
	});

	$tabContents.each(function(i, elem) {
		var $tabContent = $(elem);
		$tabContent.css("display", "none");
	});

	$tabList[0].attr('class', 'active');
	$tabContent[0].css("display", "block");
}
