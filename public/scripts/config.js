require.config({
  hbs: {
    disableI18n: true
  },
  shim: {
    underscore: {
      exports: "_"
    },
    backbone: {
      deps: ["underscore", "jquery"],
      exports: "Backbone"
    },
    "socket.io": {
      exports: "io"
    },
    "uri": {
      exports: "URI"
    },
    "handlebars": {
      exports: "Handlebars"
    }
  },
  paths: {
    jquery: "vendor/jquery",
    handlebars: "vendor/handlebars",
    underscore: "vendor/underscore",
    json2: "vendor/json2",
    i18nprecompile: "vendor/i18nprecompile",
    backbone: "vendor/backbone",
    moment: "vendor/moment",
    uri: "vendor/URI",
    "socket.io": "vendor/socket.io",
    "coffee-script": "vendor/coffee-script"
  }
});
