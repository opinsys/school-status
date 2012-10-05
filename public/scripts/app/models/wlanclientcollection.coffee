
define [
  "cs!app/models/wlanclientmodel"
  "backbone"
  "underscore"
], (WlanClientModel, Backbone, _) ->

  class WlanClientCollection extends Backbone.Collection

    model: WlanClientModel
