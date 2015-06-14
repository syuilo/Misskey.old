require! {
	gulp
	'gulp-lint-ls': lint-ls
	'gulp-livescript': ls
}

task = gulp~task
src = gulp~src

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

task \test <[ build lint ]>

task \lint ->
	src './**/*.ls'
		.pipe lint-ls {+allow-case, +allow-null, +allow-void, +allow-this, +allow-new, +allow-throw, +allow-delete}

task \default <[ build ]>
