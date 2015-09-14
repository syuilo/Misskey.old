$ ->
	$ \body .css \margin-top "#{$ 'body > #misskey-main-header' .outer-height!}px"
	$ \#misskey-main-nav .css \margin-top "#{$ 'body > #misskey-main-header' .outer-height!}px"

$ window .load ->
	$ \body .css \margin-top "#{$ 'body > #misskey-main-header' .outer-height!}px"
	$ \#misskey-main-nav .css \margin-top "#{$ 'body > #misskey-main-header' .outer-height!}px"
