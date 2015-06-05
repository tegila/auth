path = require 'path'

process.env.PORT = process.env.PORT or 8080

config = (grunt) ->
  sftp:
    test:
      files:
        "./": ["server.*", "package.json", "app/**", "views/**", "config/**"]
      options:
        path: '/var/www/auth/'
        host: '192.168.1.112'
        username: 'root'
        privateKey: grunt.file.read("/Users/tegila/.ssh/id_dsa")
        showProgress: true
        createDirectories: true
  sshexec:
    test:
      command: 'sh /var/www/auth/server.sh stop ; nohup sh /var/www/auth/server.sh start'
      options:
        host: '192.168.1.112'
        username: 'root'
        privateKey: grunt.file.read("/Users/tegila/.ssh/id_dsa")

  globals:
    exports: true


module.exports = (grunt) ->
  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks
  grunt.initConfig config(grunt)
    
  ## default
  grunt.registerTask "default", ["deploy"]
  grunt.registerTask "deploy", ["sftp", "sshexec"]

