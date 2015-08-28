$ ->
	$ '.status-timeline-frequency input:radio' .change ->
		$input = $ @
		if $input.val! == \not-rated
			$ '.status-timeline-usability' .attr \disabled yes
		else
			$ '.status-timeline-usability' .attr \disabled no
	
	$ '.status-timeline-usability input:radio' .change ->
		$input = $ @
		if ($input.val! == \bad) or ($input.val! == \very-bad)
			$ '.status-timeline-usability .suggestion' .attr \disabled no
		else
			$ '.status-timeline-usability .suggestion' .attr \disabled yes