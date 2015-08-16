module.exports = (grunt) ->
  grunt.initConfig
    env:
      dev:
        WORKERS: 1
        COFFEECOV_INIT_ALL: false
    watch:
      app:
        files: ['src/**/*.coffee']
        tasks: ['develop']
        options:
          spawn: false
          atBegin: true
    develop:
      server:
        file: 'src/cluster.coffee'
        cmd: 'coffee'
    coffee:
      compile:
        files: [
          expand: true
          bare: true
          cwd: 'src'
          src: '**/*.coffee'
          dest: 'app/'
          ext: '.js'
        ]
    coffeelint:
      app: 'src/**/*.coffee'
    mochaTest:
      test:
        options:
          reporter: 'spec'
          require: 'coffee-script/register'
        src: ['test/**/*.coffee']
      coverage:
        options:
          quiet: true
          reporter: 'spec'
          require: 'coffee-coverage/register-istanbul'
          compilers: 'coffee-script/register'
        src: ['test/helpers/*.coffee', 'test/models/*.coffee']
    makeReport:
      src: 'coverage/*.json'
      options:
        type: 'html'
        dir: 'coverage/reports'
        print: 'detail'
    clean:
      all: ['coverage/', 'app/']
      js: ['app/']
      reports: ['coverage/']
      coverage: ['coverage/coverage-coffee.json']
    fileExists:
      coverage: 'coverage/coverage-coffee.json'

  grunt.loadNpmTasks 'grunt-env'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-develop'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-istanbul'
  grunt.loadNpmTasks 'grunt-file-exists'

  grunt.registerTask 'default', ['env:dev', 'watch:app']
  grunt.registerTask 'test', ['env:dev', 'coffeelint', 'mochaTest:test']
  grunt.registerTask 'coverage', ['clean:reports', 'env:dev', 'mochaTest:coverage']
  grunt.registerTask 'mkreport', ['fileExists:coverage', 'makeReport', 'clean:coverage']
  grunt.registerTask 'build', ['clean:js', 'coffee']
  grunt.registerTask 'cleanup', ['clean:all']
