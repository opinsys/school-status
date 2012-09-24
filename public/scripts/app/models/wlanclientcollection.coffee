
define [
  "cs!app/models/wlanclientmodel"
  "backbone"
  "underscore"
], (WlanClientModel, Backbone, _) ->

  class WlanClientCollection extends Backbone.Collection

    model: WlanClientModel

    activeClientCount: ->
      connectedCount = @reduce (memo, m) ->
        if m.isConnected() then memo+1 else memo
      , 0
