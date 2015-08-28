$ ->
	$ '.status-timeline-frequency input:radio' .change ->
		$input = $ @
		if $input.val! == \not-rated
			$ '.status-timeline-usability' .attr \disabled yes
		else
			$ '.status-timeline-usability' .attr \disabled no