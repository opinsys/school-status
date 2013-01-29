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
      @url = "/log/#{ options.organisation }/desktop"
      @seen = {}

      ###*
      # Events to ignore before a 'bootend' event
      ###
      @startIgnore = {
        shutdown: true
        logout: true
      }

    parse: (data) ->

      # Ensure numeric date timestamps
      _.each data, (entry) =>
        entry.date = Number(entry.date)

      # Sort by date
      data.sort (a, b) -> a.date - b.date

      _.each data, (entry) =>
        _.each seriesMap[entry.event], (seriesName) =>
          @pushToSeries(seriesName, entry, silent: true) if seriesName

      return {}


    pushToSeries: (seriesName, entry, options) ->
      series = @get(seriesName)

      if entry.event is "login" and not @seen[entry.hostname]
        @pushToSeries("power", _.extend({}, entry, {
          event: "bootend"
        }))

      if @startIgnore[entry.event] and not @seen[entry.hostname]
        return

      @seen[entry.hostname] = true

      if last = _.last(series)
        next = _.clone(last)
        next.date = entry.date
        next.count += op[entry.event]
      else
        next = {
          count: 1
          date: entry.date
        }

      series.push(next)
      @set(seriesName, series, options)

