define [
  "cs!app/view"
  "moment"
  "uri"
  "underscore"
], (View, moment, URI, _) ->

  class TotalStats extends View

    className: "bb-total-stats"
    templateQuery: "#total-stats"

    constructor: (opts) ->
      super
      @clients = opts.clients
      @hosts = opts.hosts

      [@model, @clients, @hosts].forEach (eventEmitter) =>
        eventEmitter.on "add change remove", =>
          @render()


    renderTimer: ->

      clearTimeout @timer if @timer

      lastJoin = @clients.max (m) ->
        if not m.isConnected()
          return "0"
        m.get("relay_timestamp")

      return if not lastJoin

      lastJoinSec = (Date.now() / 1000)  - parseInt(lastJoin.get("relay_timestamp"), 10)
      lastJoinSec = Math.round lastJoinSec

      if 0 > lastJoinSec
        lastJoinSec = 0

      if lastJoinSec > 60
        msg = moment.unix(lastJoin.get("relay_timestamp")).fromNow()
      else
        msg = lastJoinSec + " seconds ago"

      @$(".lastJoin").text msg
      @$(".now").text moment().format "YYYY-MM-DD HH:mm:ss"

      @timer = setTimeout =>
        @timer = null
        @renderTimer()
      , 1000

    render: ->
      super
      @renderTimer()

    viewJSON: ->

      # FIXME: will fail with zero events
      firstEntry = @clients.min (m) -> m.get("relay_timestamp")
      if firstEntry
        time = moment.unix(firstEntry.get("relay_timestamp"))
      else
        time = moment()

      eventCount = @model.get("eventCount")
      url = URI(window.location.href)
      moreUrl =  url.query(events: eventCount + 1000).toString()
      lessUrl =  url.query(events: Math.max(eventCount - 1000, 1000)).toString()

      connectedCount: @clients.reduce (memo, m) ->
        if m.isConnected() then memo+1 else memo
      , 0
      seenCount: @clients.size()
      hostCount: @hosts.size()
      eventCount: eventCount
      schoolName: @model.get("schoolName")
      logStart: time.format "YYYY-MM-DD HH:mm:ss"
      logStartAgo: time.fromNow()
      moreUrl:  moreUrl
      lessUrl: lessUrl

