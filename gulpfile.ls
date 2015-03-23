require! {
	gulp
	'gulp-plumber': plumber
	'gulp-livescript': ls
}

paths =
	ls: './src/**/*.ls'
	package-json: './package.json.ls'

gulp.task \build-package-json ->
	gulp.src paths.package-json
		.pipe plumber!
		.pipe ls!
		.on \error (console.log.bind console)
		.pipe gulp.dest './'

gulp.task \build <[ build-package-json ]>

gulp.task \watch <[ build ]> ->
	gulp.watch paths.package-json, <[ build-package-json ]>

gulp.task \test ->
	gulp.src paths.ls
		.pipe ls!
		.on \error -> throw it

gulp.task \default <[ build ]>
