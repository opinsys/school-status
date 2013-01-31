define [
  "backbone"
  "underscore"
], (
  Backbone
  _
) ->

  op = {
    bootend: 1
    shutdown: -1
    login: 1
    logout: -1
  }

  seriesMap = {
    bootend: ["power"]
    shutdown: ["power", "login"]
    login: ["login"]
    logout: ["login"]
  }

  class HistoryGraphModel extends Backbone.Model

    defaults: ->
      power: []
      login: []

    constructor: (attrs, options) ->
      super

      query = _.extend({
        projection: [
          "type"
          "event"
          "hostname"
          "date"
        ]
      }, options.query)

      @url = "/log/#{ options.organisation }/desktop?#{ $.param(query) }"
      console.log "Model query from #{ @url }"

      @seen = {}
      @rawData = []

      ###*
      # Events to ignore before a 'bootend' event
      ###
      @startIgnore = {
        shutdown: true
        logout: true
      }


    getMachineNames: -> _.uniq _.map @rawData, (e) -> e.hostname

    fetch: ->
      @set("power", [], silent: true)
      @set("login", [], silent: true)
      @rawData = []
      @seen = {}
      super

    parse: (data) ->
      @rawData = @rawData.concat(data)

      # Ensure numeric date timestamps
      _.each data, (entry) =>
        entry.date = Number(entry.date)

      # Sort by date
      data.sort (a, b) -> a.date - b.date


      _.each data, (entry) =>
        console.log entry.event, entry.hostname, new Date(entry.date)
        _.each seriesMap[entry.event], (seriesName) =>
          @pushToSeries(seriesName, entry, silent: true) if seriesName

      return {}

    pushToSeries: (seriesName, entry, options) ->
      series = @get(seriesName)

      if entry.event is "login" and not @seen[entry.hostname]
        @pushToSeries("power", _.extend({}, entry, {
          event: "bootend"
        }))

      if entry.event is "shutdown" and @seen[entry.hostname]?.login
        @pushToSeries("login", _.extend({}, entry, {
          event: "logout"
        }))

      if @startIgnore[entry.event] and not @seen[entry.hostname]
        return

      state = @seen[entry.hostname] ?= {
        bootend: false
        login: false
      }

      if entry.event is "shutdown" and not state.bootend
        return

      if last = _.last(series)
        next = _.clone(last)
        next.date = entry.date
        if not state[entry.event]
          next.count += op[entry.event]
      else
        next = {
          count: 1
          date: entry.date
        }

      if entry.event in ["bootend", "login", "logout"]
        state.bootend = true
      if entry.event is "shutdown"
        state.bootend = false
      if entry.event is "login"
        state.login = true
      if entry.event is "logout"
        state.login = false

      series.push(next)
      @set(seriesName, series, options)

