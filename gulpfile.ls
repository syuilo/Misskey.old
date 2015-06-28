require! {
	gulp
	'gulp-livescript': ls
}

{task, src} = {gulp~task, gulp~src}

task \build <[ build-package-json build-ls build-copy ]>

task \build-package-json ->
	src './package.json.ls'
		.pipe ls!
		.pipe gulp.dest './'

task \build-ls ->
	src './src/**/*.ls' ->
		.pipe ls!
		.pipe gulp.dest './lib'

task \build-copy ->
	src <[ ./src/**/* !./src/**/*.ls ]>
		.pipe gulp.dest './lib'

task \test <[ build ]>

task \default <[ build ]>
