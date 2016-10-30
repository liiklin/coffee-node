gulp = require('gulp')
gutil = require('gulp-util')
uglify = require('gulp-uglify')
coffee = require('gulp-coffee')
coffeelint = require('gulp-coffeelint')
sourcemaps = require('gulp-sourcemaps')

# 文件路径
banckend_coffeescript_files = 'src/server/**/*.coffee'
banckend_build_dir = 'app'

frontend_coffeescript_files = 'src/client/**/*.coffee'
frontend_build_dir = 'static/js/app'

# 任务列表
gulp.task 'validate_coffee_backend', ->
  gulp.src banckend_coffeescript_files
  .pipe coffeelint()
  .pipe coffeelint.reporter()

gulp.task 'compile_coffee_backend', [ 'validate_coffee_backend' ], ->
  gulp.src banckend_coffeescript_files
  .pipe sourcemaps.init()
  .pipe coffee bare: false
  .pipe uglify()
  .pipe sourcemaps.write './'
  .on 'error', gutil.log
  .pipe gulp.dest banckend_build_dir

gulp.task 'validate_coffee_frontend', ->
  gulp.src frontend_coffeescript_files
  .pipe coffeelint()
  .pipe coffeelint.reporter()

gulp.task 'compile_coffee_frontend', [ 'validate_coffee_frontend' ], ->
  gulp.src frontend_coffeescript_files
  .pipe sourcemaps.init()
  .pipe coffee bare: true
  .pipe uglify()
  .pipe sourcemaps.write './'
  .on 'error', gutil.log
  .pipe gulp.dest frontend_build_dir

gulp.task 'watch', ->
  gulp.watch banckend_coffeescript_files, ['compile_coffee_backend']
  gulp.watch frontend_coffeescript_files, ['compile_coffee_frontend']

# 执行任务
gulp.task 'default', ['compile_coffee_frontend', 'compile_coffee_backend'], ->
  console.log 'run default task'

gulp.task 'dev', ['compile_coffee_frontend', 'compile_coffee_backend','watch'], ->
  console.log 'run dev task'
