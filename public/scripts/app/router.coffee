define [
  "cs!app/views/lightbox"
  "cs!app/views/wlanhostdetails"
  "cs!app/views/wlanclientdetails"
  "jquery"
  "underscore"
  "backbone"
], (
  Lightbox
  WlanHostDetails
  WlanClientDetails
  $,
  _,
  Backbone,
  io,
) ->

  class Router extends Backbone.Router


    constructor: (opts) ->
      super
      @clients = opts.clients
      @hosts = opts.hosts

      @hosts.on "host-details", (model) =>
        @navigate "host/#{ model.id }", trigger: true

      @clients.on "client-details", (model) =>
        @navigate "client/#{ model.id }", trigger: true


    routes:
      "": "main"
      "host/:id": "showHost"
      "client/:id": "showClient"

    main: ->
      Lightbox.current?.remove()


    showClient: (id) ->
      if model = @clients.get id
        @_lightboxView new WlanClientDetails
          hosts: @hosts
          model: model
      else
        @_showError "Unknown wlan client #{ id }"

    showHost: (id) ->
      if model = @hosts.get id
        @_lightboxView new WlanHostDetails
          model: model
      else
        @_showError "Unknown wlan host #{ id }"

    _showError: (msg) ->
      view = new Backbone.View
      view.render = ->
        @$el.html "<h1 class=error>Error</h1><p>#{msg}</p>"
      @_lightboxView view


    _lightboxView: (view) ->
      lb = new Lightbox view: view
      lb.render()
      lb.on "close", =>
        @navigate "", trigger: true

