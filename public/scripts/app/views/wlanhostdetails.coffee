define [
  "cs!app/view"
  "jquery"
  "moment"
  "underscore"
], (
  View
  $
  moment
  _) ->
  class WlanHostDetails extends View

    className: "bb-wlan-host-details"
    templateQuery: "#wlan-host-details"

    constructor: (opts) ->
      super
      @model.clients.on "add remove change", =>
        @render()

    events:
      "click a.client": (e) ->
        e.preventDefault()
        mac = $(e.target).data("mac")
        model = @model.allClients.get(mac)
        @model.allClients.trigger "client-details", model


    formatClient: (m) ->
      time = moment.unix(m.get "relay_timestamp")
      mac: m.get "mac"
      ago: time.fromNow()
      time: time.format "YYYY-MM-DD HH:mm:ss"
      manufacturer: m.get "client_manufacturer"
      clientHostname: m.get "client_hostname"
      timestamp: parseInt(m.get "relay_timestamp")

    _shortFormated: (a, b) ->
      b.timestamp - a.timestamp

    viewJSON: ->
      connected = []
      seen = []

      @model.clients.each (m) =>
        if m.isConnected()
          connected.push @formatClient m
        else
          seen.push @formatClient m

      connected.sort @_shortFormated
      seen.sort @_shortFormated

      return {
        count: @model.activeClientCount()
        name: @model.id
        connected: connected
        seen: seen
      }
