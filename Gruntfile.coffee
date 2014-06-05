module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-espower'
  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    watch:
      files: ['test/**/*.coffee', 'scripts/*.coffee']
      tasks: 'test'
    clean:
      test: ['test/js', 'test/espowered']
    coffee:
      compile:
        files: [
          expand: true
          cwd: 'test/'
          src: ['**/*.coffee']
          dest: 'test/js'
          ext: '.js'
        ]
    espower:
      test:
        files: [
          expand: true,       #Enable dynamic expansion,
          cwd: 'test/js',       #Src matches are relative to this path
          src: ['**/*.js'],   #Actual pattern(s) to match
          dest: 'test/espowered/', #Destination path prefix
          ext: '.js'          #Dest filepaths will have this extension
        ]
    mochaTest:
      test:
        options:
          ui: 'bdd'
          require: ['intelli-espower-loader', 'coffee-script/register']
        src: ['test/js/*.js']

  grunt.registerTask 'default', ['watch']
  grunt.registerTask 'test', ['clean', 'coffee', 'espower', 'mochaTest']
