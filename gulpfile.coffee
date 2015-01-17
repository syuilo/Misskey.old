gulp = require 'gulp'
ts = require 'gulp-typescript'
del = require 'del'

gulp.task 'clean', del.bind(null, ['./app/**'])

gulp.task 'public-copy', ->
	gulp.src './src/public/**'
		.pipe gulp.dest './app/public/'
	gulp.src './src/lib/web/public/**'
		.pipe gulp.dest './app/lib/web/public/'
	gulp.src './src/lib/web/views/**'
		.pipe gulp.dest './app/lib/web/views/'

gulp.task 'typescript-compile', ->
	gulp.src './src/lib/**/*.ts'
		.pipe ts
			target: 'ES5'
			removeComments: true
			noImplicitAny: true
			declarationFiles: false
		.js
		.pipe gulp.dest './app/lib/'

gulp.task 'watch', ['build'], ->
	gulp.watch './src/lib/*.ts', ['typescript-compile']
	gulp.watch './src/public/**', ['public-copy']

gulp.task 'build', ['public-copy', 'typescript-compile']

gulp.task 'default', ['clean', 'build']
