$ ->
	$ \#accept .click ->
		$form = $ \#form
		$form.submit!
	
	$ \#cancel .click ->
		$form = $ \#form
		$form.find '[name=\'cancel\']' .attr \value \true
		$form.submit!