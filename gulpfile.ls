require! {
	gulp
	'gulp-lint-ls': lint-ls
	'gulp-livescript': ls
}

gulp.task \build <[ build-package-json build-ls build-copy ]>

gulp.task \build-package-json ->
	gulp.src './package.json.ls'
		.pipe ls!
		.pipe gulp.dest './'

gulp.task \build-ls ->
	gulp.src './src/**/*.ls' ->
		.pipe ls!
		.pipe gulp.dest './lib/'

gulp.task \build-copy ->
	gulp.src <[ ./src/**/* !./src/**/*.ls ]>
		.pipe gulp.dest './lib/'

gulp.task \test <[ build lint ]>

gulp.task \lint ->
	gulp.src './**/*.ls'
		.pipe lint-ls {+allow-case, +allow-null, +allow-void, +allow-this, +allow-new, +allow-throw, +allow-delete}

gulp.task \default <[ build ]>
