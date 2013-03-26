define [
  "backbone"
  "underscore"
  "moment"
], (Backbone, _, moment) ->

  class WlanClientModel extends Backbone.Model

    connectEvent: "AP-STA-CONNECTED"

    constructor: (opts) ->
      opts.id = opts.mac
      super
      @history = []

    isConnected: -> !!@get("hostname")

    getTimestampAsMs: ->
      stamp = parseInt(@get("relay_timestamp"), 10)
      if stamp.toString().length is 10
        # In old logrelay version stamps where in seconds (from Ruby
        # Time.now.to_i). Detect those and convert them to milliseconds. This
        # conversion has obvious flaws, but they do not affect in our use case
        return stamp * 1000
      return stamp

    getTimestampAsMoment: -> moment.unix(@getTimestampAsMs() / 1000)

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

