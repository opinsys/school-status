define [
  "cs!app/view"
  "jquery"
  "moment"
  "underscore"
], (View, $, moment, _) ->
  class WlanClientDetails extends View

    className: "bb-wlan-client-details"
    templateQuery: "#wlan-client-details"

    constructor: (opts) ->
      super
      @hosts = opts.hosts
      @model.on "change", => @render()

    events: ->
      "click a.host": (e) ->
        e.preventDefault()
        model = @hosts.get $(e.target).data("host")
        @hosts.trigger "host-details", model


    viewJSON: ->
      history = @model.history.map (e) ->
        time = moment.unix(e.timestamp)
        return (
          hostname: e.hostname
          event: e.event
          ago: time.fromNow()
          time: time.format "YYYY-MM-DD HH:mm:ss"
        )

      return {
        mac: @model.id
        hostname: @model.get "hostname"
        manufacturer: @model.get "client_manufacturer"
        history: history
        clientHostname: @model.get "client_hostname"
      }
