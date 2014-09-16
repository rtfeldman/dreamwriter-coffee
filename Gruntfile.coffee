extraRequires = ["react", "lodash"]

module.exports = (grunt) ->
  grunt.initConfig
    clean: ["dist"]

    watch:
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

      appcache:
        files: ["src/*.appcache"]
        tasks: ["copy"]

    connect:
      static:
        options:
          port: 9000,
          base: 'dist'

    copy:
      appcache:
        src:  "src/dreamwriter.appcache"
        dest: "dist/dreamwriter.appcache"

      index:
        src:  "src/index.html"
        dest: "dist/index.html"

      offline:
        src:  "src/index.html"
        dest: "dist/offline.html"

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

    browserify:
      options:
        requires: extraRequires
        watch: true
        extensions: ['.js', '.coffee']
        transform: ['coffeeify']
        bundleOptions:
          debug: true

      dreamwriter:
        src:  "./src/**/*.coffee"
        dest: "dist/dreamwriter.js"

      vendor:
        src:  "./vendor/**/*.js"
        dest: "dist/vendor.js"

  ["grunt-contrib-watch", "grunt-contrib-clean", "grunt-browserify", "grunt-contrib-copy", "grunt-contrib-connect", "grunt-contrib-stylus", "grunt-autoprefixer"].forEach (plugin) -> grunt.loadNpmTasks plugin

  grunt.registerTask "build", [
    "copy"
    "browserify"
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
