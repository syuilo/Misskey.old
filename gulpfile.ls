require! {
	gulp
	'gulp-lint-ls': lint-ls
	'gulp-livescript': ls
}

task = gulp~task
src = gulp~src
dest = gulp~src

task \build <[ build-package-json build-ls build-copy ]>

task \build-package-json ->
	src './package.json.ls'
		.pipe ls!
		.pipe dest './'

task \build-ls ->
	src './src/**/*.ls' ->
		.pipe ls!
		.pipe dest './lib/'

task \build-copy ->
	src <[ ./src/**/* !./src/**/*.ls ]>
		.pipe dest './lib/'

task \test <[ build lint ]>

task \lint ->
	src './**/*.ls'
		.pipe lint-ls {+allow-case, +allow-null, +allow-void, +allow-this, +allow-new, +allow-throw, +allow-delete}

task \default <[ build ]>
