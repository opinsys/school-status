define [
  "backbone"
  "underscore"
], (Backbone, _) ->

  class WlanClientModel extends Backbone.Model

    connectEvent: "AP-STA-CONNECTED"

    constructor: (opts) ->
      opts.id = opts.mac
      super
      @history = []

      @on "change add", (model) =>
        @history.unshift
          event: model.get("event")
          hostname: model.get("hostname")
          timestamp: model.get("relay_timestamp")


    isConnected: ->
      @get("event") is @connectEvent


    update: (packet) ->
      if packet.event is @connectEvent
        return @set packet

      # This is disconnect event for the current wlan host
      if packet.hostname is @get("hostname")
        return @set packet

      # Otherwise it is a delayed disconnect event from some previous host.
      # Have to just ignore it.

