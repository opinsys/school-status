require.config({
  hbs: {
    disableI18n: true
  },
  shim: {
    backbone: {
      deps: ["underscore", "jquery"],
      exports: "Backbone"
    },
   "backbone.viewmaster": {
      deps: ["backbone"],
      exports: "Backbone.ViewMaster"
    },
    "uri": {
      exports: "URI"
    },
    "bean": {
      exports: "bean",
    },
    "flotr2": {
      exports: "Flotr",
      deps: ["underscore", "bean"]
    }
  },
  paths: {
    jquery: "vendor/jquery",
    handlebars: "vendor/handlebars",
    underscore: "vendor/underscore",
    json2: "vendor/json2",
    i18nprecompile: "vendor/i18nprecompile",
    backbone: "vendor/backbone",
    "backbone.viewmaster": "vendor/backbone.viewmaster",
    moment: "vendor/moment",
    uri: "vendor/URI",
    "socket.io": "vendor/socket.io",
    "coffee-script": "vendor/coffee-script",
    "flotr2": "vendor/flotr2",
    "bean": "vendor/bean"
  }
});
