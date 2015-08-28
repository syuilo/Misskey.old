$ ->
	$ '.status-timeline-frequency .not-rated input' .change ->
		$input = $ @
		if $input.val!
			$ '.status-timeline-usability' .attr \disabled yes
		else
			$ '.status-timeline-usability' .attr \disabled no