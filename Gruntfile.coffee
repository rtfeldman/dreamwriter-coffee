extraRequires = ["react", "lodash"]

cacheHashPrefix = "dwv_"

module.exports = (grunt) ->
  grunt.initConfig
    clean: ["dist"]

    watch:
      stylus:
        files: ["src/stylesheets/**/*.styl"]
        tasks: ["stylesheets", "appcache", "hashres"]

      html:
        files: ["src/index.html"]
        tasks: ["copy:index", "copy:offline", "appcache", "hashres"]

      images:
        files: ["src/images/*.*"]
        tasks: ["copy:images", "appcache", "hashres"]

      fonts:
        files: ["src/fonts/*.*"]
        tasks: ["copy:fonts", "appcache", "hashres"]

      javascripts:
        files: ["dist/**/*.js", "!dist/**/*.#{cacheHashPrefix}*"]
        tasks: ["appcache", "hashres"]

    connect:
      static:
        options:
          port: 9000,
          base: 'dist'

    copy:
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
          map: false

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

    appcache:
      options:
        basePath: 'dist'

      all:
        dest:     'dist/dreamwriter.appcache'
        cache:    patterns: ['dist/**/*', '!dist/index.html']
        network:  '*'
        fallback: [
          '/           /offline.html'
          '/index.html /offline.html'
        ]

    hashres:
      options:
        fileNameFormat: "${name}.#{cacheHashPrefix}${hash}.${ext}",
        renameFiles: true
      all:
        src: [
          "dist/**/*.*",
          "!dist/index.html"
          "!dist/dreamwriter.appcache"
        ]
        dest: [
          'dist/*.html'
          'dist/*.css'
          'dist/*.appcache'
        ]

  ["grunt-contrib-watch", "grunt-contrib-clean", "grunt-browserify", "grunt-contrib-copy", "grunt-contrib-connect", "grunt-contrib-stylus", "grunt-autoprefixer", "grunt-appcache", "grunt-hashres"].forEach (plugin) -> grunt.loadNpmTasks plugin

  grunt.registerTask "build", [
    "stylesheets"
    "browserify"
    "copy"
    "appcache"
    "hashres"
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
