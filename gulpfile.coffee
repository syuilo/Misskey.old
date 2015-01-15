gulp = require 'gulp'
ts = require 'gulp-typescript'
del = require 'del'

gulp.task 'clean', del.bind(null, ['./app/**'])

gulp.task 'public-copy', ->
	gulp.src './src/public/**'
		.pipe gulp.dest './app/public/'

gulp.task 'typescript-compile', ->
	gulp.src './src/lib/*.ts'
		.pipe ts
			target: 'ES5'
			removeComments: true
			noImplicitAny: true
			declarationFiles: false
		.js
		.pipe gulp.dest './app/lib/'
	gulp.src './src/lib/model/*.ts'
		.pipe ts
			target: 'ES5'
			removeComments: true
			noImplicitAny: true
			declarationFiles: false
		.js
		.pipe gulp.dest './app/lib/model/'
	gulp.src './src/lib/web/*.ts'
		.pipe ts
			target: 'ES5'
			removeComments: true
			noImplicitAny: true
			declarationFiles: false
		.js
		.pipe gulp.dest './app/lib/web/'
	gulp.src './src/lib/web/models/*.ts'
		.pipe ts
			target: 'ES5'
			removeComments: true
			noImplicitAny: true
			declarationFiles: false
		.js
		.pipe gulp.dest './app/lib/web/models/'

gulp.task 'watch', ['build'], ->
	gulp.watch './src/lib/*.ts', ['typescript-compile']
	gulp.watch './src/public/**', ['public-copy']

gulp.task 'build', ['public-copy', 'typescript-compile']

gulp.task 'default', ['clean', 'build']
