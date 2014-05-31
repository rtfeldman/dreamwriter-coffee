module.exports = (grunt) ->
  grunt.initConfig
    clean: ["dist"]

    watch:
      coffee:
        files: ["src/**/*.coffee"]
        tasks: ["coffeeify"]

      html:
        files: ["src/*.html"]
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

    coffeeify:
      options:
        debug: true
        extensions: ['.js', '.coffee']

      dreamwriter:
        src:  "./src/**/*.coffee"
        dest: "dist/dreamwriter.js"

  ["grunt-contrib-watch", "grunt-contrib-clean", "grunt-coffeeify", "grunt-contrib-copy", "grunt-contrib-connect"].forEach (plugin) -> grunt.loadNpmTasks plugin

  grunt.registerTask "build", [
    "copy"
    "coffeeify"
  ]

  grunt.registerTask "default", [
    "clean"
    "build"
    "connect"
    "watch"
  ]
