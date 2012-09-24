define [
  "cs!app/models/wlanhostmodel"
  "cs!app/models/wlanclientmodel"
  "cs!app/views/wlanstats"
], (
  WlanHostModel
  WlanClientModel
  WlanStats
) ->

  # Routes and parses log events to appropriate Backbone models and collections
  class LogRouter

    constructor: ({@hosts, @clients, @school}) ->

    handle: (packet) ->

      @school.incEventCount()

      if packet.wlan_event is "hotspot_state"
        @_setState packet
      else
        @_setClient packet


    # Handle event packet. Adds or updates given client
    _setClient: (packet) ->
      console.info "Updating client from", packet
      client = @clients.get packet.mac

      # Just update existing client
      if client
        client.set packet
      else
        # Add packet as new client
        @clients.add new WlanClientModel packet

      @_createHostFromClient packet

    # Handle state packet. This is will reset all clients in a single wlan host
    # to a given state
    _setState: (packet) ->
      console.info "Setting state from", packet
      @_updateClientsFromState packet
      @_updateHostsFromState packet


    _updateClientsFromState: (packet) ->

      for mac in packet.connected_devices

        client = @clients.get mac
        if client
          # Remove client from other wlan hosts and add it here.
          client.set
            hostname: packet.hostname
            event: WlanClientModel::connectEvent
        else
          client = @_createClientFromState mac, packet.hostname

    _updateHostsFromState: (packet) ->
      host = @hosts.get packet.hostname
      # Make sure that all devices that are not connected are removed from the
      # model's collection
      host.clients.each (model) ->
        if packet.connected_devices.indexOf(model.id) is -1
          host.clients.remove(model)

    _createClientFromState: (mac, hostname) ->
      client = new WlanClientModel
        mac: mac
        event: WlanClientModel::connectEvent
        hostname: hostname
        # We don't actually know when this client has connected...
        relay_timestamp: Date.now()

      @clients.add client
      return client

    # Create new WlanHostModel if this client packet introduces new Wlan Host
    _createHostFromClient: (packet) ->

      if not @hosts.get(packet.hostname)
        console.info "creating new host view", packet.hostname
        @hosts.add new WlanHostModel
          id: packet.hostname
          allClients: @clients


