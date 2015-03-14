require! {
	gulp
	del
	'gulp-plumber': plumber
	'gulp-typescript': ts
	'gulp-livescript': ls
}

paths =
	ts: './src/**/*.ts'
	ls: './src/**/*.ls'
	webRes: './src/web/resources/**/**'
	webViews: './src/web/views/**/*.jade'
	webDevReferences: './src/reference/**/*.jade'

gulp.task \clean del.bind(null, ['./bin/**'])

gulp.task \build-ls ->
	gulp.src paths.ls
		.pipe plumber!
		.pipe ls!
		.on \error (console.log.bind console)
		.pipe gulp.dest './bin/'

gulp.task \build-ts ->
	gulp.src paths.ts
		.pipe plumber!
		.pipe ts do
			target: \ES5
			module: \commonjs
			removeComments: true
			noImplicitAny: true
			declarationFiles: false
		.js
		.pipe gulp.dest './bin/'

gulp.task \build-web-res ->
	gulp.src paths.webRes
		.pipe plumber!
		.pipe gulp.dest './bin/web/resources'

gulp.task \build-web-views ->
	gulp.src paths.webViews
		.pipe plumber!
		.pipe gulp.dest './bin/web/views'
	gulp.src paths.webDevReferences
		.pipe plumber!
		.pipe gulp.dest './bin/reference'

gulp.task \build <[ build-ls build-ts build-web-res build-web-views ]>

gulp.task \watch <[ build ]> ->
	gulp.watch paths.ls, <[ build-ls ]>
	gulp.watch paths.ts, <[ build-ts ]>
	gulp.watch paths.webRes, <[ build-web-res ]>
	gulp.watch paths.webViews, <[ build-web-views ]>

gulp.task \default <[ build ]>