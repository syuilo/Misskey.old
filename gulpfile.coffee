gulp = require 'gulp'
ts = require 'gulp-typescript'
del = require 'del'

paths =
	ts: './src/**/*.ts'
	webRes: './src/web/statics/resources/**/**'
	webViews: './src/web/views/**/*.jade'
	webCommon: './src/web/common/**'

gulp.task 'clean', del.bind(null, ['./bin/**'])

gulp.task 'build-ts', ->
	gulp.src paths.ts
		.pipe ts
			target: 'ES5'
			module: 'commonjs'
			removeComments: true
			noImplicitAny: true
			declarationFiles: false
		.js
		.pipe gulp.dest './bin/'

gulp.task 'build-web-res', ->
	gulp.src paths.webRes
		.pipe gulp.dest './bin/web/statics/resources'

gulp.task 'build-web-views', ->
	gulp.src paths.webViews
		.pipe gulp.dest './bin/web/views'

gulp.task 'build-web-common', ->
	gulp.src paths.webCommon
		.pipe gulp.dest './bin/web/common'
		.pipe gulp.dest './bin/web/statics/resources/common'

gulp.task 'build', ['build-ts', 'build-web-res', 'build-web-views', 'build-web-common']

gulp.task 'watch', ['build'], ->
	gulp.watch paths.ts, ['build-ts']
	gulp.watch paths.webRes, ['build-web-res']
	gulp.watch paths.webViews, ['build-web-views']
	gulp.watch paths.webCommon, ['build-web-common']

gulp.task 'default', ['build']