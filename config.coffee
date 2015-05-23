exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    stylesheets:
      joinTo: 'stylesheets/app.css'
      order:
        before: [
          'app/stylesheets/pure.css'
        ]
        after: [
          'app/stylesheets/branchenbuch.less'
          'app/stylesheets/menu.less'          
        ]
      
    javascripts:
      joinTo: 'javascripts/app.js'
      order:
        before: [
          'vendor/scripts/zepto-1.1.3.js',
          'vendor/scripts/zepto-fx.js',
          'vendor/scripts/underscore.js',
          'vendor/scripts/facetedsearch.js'
          
        ]
        after: [
          'vendor/scripts/firmen.js',
          'vendor/scripts/branchenbuch.js'
        ]

    templates:
      joinTo: 
      	'js/templates.js': /.+\.jade$/

  imageoptimizer:
    smushit: false # if false it use jpegtran and optipng, if set to true it will use smushit
    path: 'img'

  plugins:
    jade:
      options:          # can be added all the supported jade options
        pretty: yes     # Adds pretty-indentation whitespaces to output (false by default)
    static_jade:                        # all optionals
      #extension:  ".jade"        # static-compile each file with this extension in `assets`
      path:       [ /app/ ]  # static-compile each file in this directories
      #asset:      "app/jade_asset"      # specify the compilation output

    autoReload:
      enabled:
        css: on
        js: on
        assets: on
      