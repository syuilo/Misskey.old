$ ->
	$ \body .css \margin-top "#{$ 'body > #misskey-main-header' .outer-height!}px"
	
$ window .load ->
	header-height = $ 'body > #misskey-main-header' .outer-height!
	$ \body .css \margin-top "#{header-height}px"
	$ \html .css \background-position "center #{header-height}px"
	
