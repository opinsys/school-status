define [
  "cs!app/models/wlanclientcollection"
  "backbone"
  "underscore"
], (
  WlanClientCollection,
  Backbone,
  _
) ->

  class WlanHostModel extends Backbone.Model

    constructor: (opts) ->
      if not opts.id
        opts.id = opts.hostname

      super

      @allClients = opts.allClients

      @clients = new WlanClientCollection

      @allClients.each (model) => @handleClient model
      @allClients.on "add change", (model, e) =>
        @handleClient model

    handleClient: (model) ->
      if model.get("hostname") is @id
        @clients.add model

    activeClientCount: ->
      @clients.reduce (memo, m) =>
        if m.get("hostname") is @id then memo+1 else memo
      , 0

