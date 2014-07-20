module.exports = (grunt) ->
  grunt.initConfig
    clean: ["dist"]

    watch:
      coffee:
        files: ["src/**/*.coffee"]
        tasks: ["coffeeify"]

      stylus:
        files: ["src/stylesheets/**/*.styl"]
        tasks: ["stylus"]

      html:
        files: ["src/**/*.html"]
        tasks: ["copy"]

    connect:
      static:
        options:
          port: 9000,
          base: 'dist'

    copy:
      html:
        src:  "src/index.html"
        dest: "dist/index.html"

    stylus:
      compile:
        options:
          paths: ["src/stylesheets/*.styl"]
        files:
          "dist/dreamwriter.css": ["src/stylesheets/*.styl"]

    coffeeify:
      options:
        debug: true
        extensions: ['.js', '.coffee']

      dreamwriter:
        src:  "./src/**/*.coffee"
        dest: "dist/dreamwriter.js"

      vendor:
        src:  "./vendor/**/*.js"
        dest: "dist/vendor.js"

  ["grunt-contrib-watch", "grunt-contrib-clean", "grunt-coffeeify", "grunt-contrib-copy", "grunt-contrib-connect", "grunt-contrib-stylus"].forEach (plugin) -> grunt.loadNpmTasks plugin

  grunt.registerTask "build", [
    "copy"
    "coffeeify"
    "stylus"
  ]

  grunt.registerTask "default", [
    "clean"
    "build"
    "connect"
    "watch"
  ]
