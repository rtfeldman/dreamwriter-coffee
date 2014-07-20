module.exports = (grunt) ->
  grunt.initConfig
    clean: ["dist"]

    watch:
      coffee:
        files: ["src/**/*.coffee"]
        tasks: ["coffeeify"]

      stylus:
        files: ["src/stylesheets/**/*.styl"]
        tasks: ["stylesheets"]

      html:
        files: ["src/**/*.html"]
        tasks: ["copy"]

      images:
        files: ["src/images/*.*"]
        tasks: ["copy"]

      fonts:
        files: ["src/fonts/*.*"]
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

      images:
        expand: true
        cwd: "src"
        src: "images/**"
        dest: "dist/"

      fonts:
        expand: true
        cwd: "src"
        src: "fonts/**"
        dest: "dist/"

    stylus:
      compile:
        options:
          paths: ["src/stylesheets/*.styl"]
        files:
          "dist/dreamwriter.css": ["src/stylesheets/*.styl"]

    autoprefixer:
      dreamwriter:
        options:
          map: true

        src: "dist/dreamwriter.css"
        dest: "dist/dreamwriter.css"

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

  ["grunt-contrib-watch", "grunt-contrib-clean", "grunt-coffeeify", "grunt-contrib-copy", "grunt-contrib-connect", "grunt-contrib-stylus", "grunt-autoprefixer"].forEach (plugin) -> grunt.loadNpmTasks plugin

  grunt.registerTask "build", [
    "copy"
    "coffeeify"
    "stylesheets"
  ]

  grunt.registerTask "stylesheets", [
    "stylus"
    "autoprefixer"
  ]

  grunt.registerTask "default", [
    "clean"
    "build"
    "connect"
    "watch"
  ]
