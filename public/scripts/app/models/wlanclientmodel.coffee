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

    isConnected: -> !!@get("hostname")

    update: (packet) ->

      @history.unshift
        event: packet.event
        hostname: packet.hostname
        timestamp: packet.relay_timestamp

      # Connected to a new host
      if packet.event is @connectEvent
        return @set packet

      # This is disconnect event for the current wlan host
      if packet.hostname is @get("hostname")
        packet = _.clone packet
        packet.hostname = null
        return @set packet

      # Otherwise it is a delayed disconnect event from some previous host.
      # Have to just ignore it.

