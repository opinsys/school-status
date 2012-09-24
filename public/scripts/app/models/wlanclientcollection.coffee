
define [
  "cs!app/models/wlanclientmodel"
  "backbone"
  "underscore"
], (WlanClientModel, Backbone, _) ->

  class WlanClientCollection extends Backbone.Collection

    model: WlanClientModel

    # Client collection from a log packet
    update: (packet) ->
      if packet.wlan_event is "hotspot_state"
        return @setState packet



      client = @get packet.mac

      # Just update existing client
      if client
        client.set packet
      else
        # Add packet as new client
        client = new @model packet
        @add client

    setState: (packet) ->
      console.info "state packet", packet
      debugger

    activeClientCount: ->
      connectedCount = @reduce (memo, m) ->
        if m.isConnected() then memo+1 else memo
      , 0
