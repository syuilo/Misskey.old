$ ->
	$ '.status-timeline-frequency input:radio' .change ->
		$input = $ @
		if $input.val! == \unused
			$ '.status-timeline-usability' .attr \disabled yes
		else
			$ '.status-timeline-usability' .attr \disabled no
	
	$ '.status-timeline-usability input:radio' .change ->
		$input = $ @
		if ($input.val! == \bad) or ($input.val! == \very-bad)
			$ '.status-timeline-usability .suggestion' .attr \disabled no
		else
			$ '.status-timeline-usability .suggestion' .attr \disabled yes
	
	$ '.talk-frequency input:radio' .change ->
		$input = $ @
		if $input.val! == \unused
			$ '.talk-usability' .attr \disabled yes
		else
			$ '.talk-usability' .attr \disabled no
	
	$ '.talk-usability input:radio' .change ->
		$input = $ @
		if ($input.val! == \bad) or ($input.val! == \very-bad)
			$ '.talk-usability .suggestion' .attr \disabled no
		else
			$ '.talk-usability .suggestion' .attr \disabled yes
	
	$ '.bbs-frequency input:radio' .change ->
		$input = $ @
		if $input.val! == \unused
			$ '.bbs-usability' .attr \disabled yes
		else
			$ '.bbs-usability' .attr \disabled no
	
	$ '.bbs-usability input:radio' .change ->
		$input = $ @
		if ($input.val! == \bad) or ($input.val! == \very-bad)
			$ '.bbs-usability .suggestion' .attr \disabled no
		else
			$ '.bbs-usability .suggestion' .attr \disabled yes
	
	$ '.design input:radio' .change ->
		$input = $ @
		if ($input.val! == \bad) or ($input.val! == \very-bad)
			$ '.design .suggestion' .attr \disabled no
		else
			$ '.design .suggestion' .attr \disabled yes