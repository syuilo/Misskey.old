require! {
	gulp
	'gulp-livescript': ls
	'gulp-notify': notify
	'gulp-plumber': plumber
}

{task, src, dest, watch} = {gulp~task, gulp~src, gulp~dest, gulp~watch}

task \build <[ build-package-json build-ls build-copy ]>

task \build-package-json ->
	src './package.json.ls'
		.pipe plumber do
			error-handler: notify.on-error 'Error <%= error.message %>'
		.pipe ls!
		.pipe dest './'

task \build-ls ->
	src './src/**/*.ls' ->
		.pipe plumber do
			error-handler: notify.on-error 'Error <%= error.message %>'
		.pipe ls!
		.pipe dest './lib'

task \build-copy ->
	src <[ ./src/**/* !./src/**/*.ls ]>
		.pipe dest './lib'

task \test <[ build ]>

task \watch <[ build ]> ->
	watch './src/**/*' <[ build ]>

task \default <[ build ]>
