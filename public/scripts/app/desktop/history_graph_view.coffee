define [
  "underscore"
  "backbone"
  "backbone.viewmaster"
  "flotr2"
], (
  _
  Backbone
  ViewMaster
  Flotr
) ->

  class HistoryGraphView extends ViewMaster

    className: "bb-history-graph"

    constructor: ->
      super
      @listenTo @model, "change sync", @render
      $(window).on "resize", _.debounce =>
        @render()
      , 500

    template: -> ""

    render: ->
      super

      @$el.width($(window).width() - 50)
      @$el.height($(window).height() - 50)

      powerData = @model.get("power")
      if powerData.length is 0
        return

      powerData = _.map powerData, (entry) ->
        [entry.date, entry.count]

      loginData = _.map @model.get("login"), (entry) ->
        [entry.date, entry.count]

      # Put zero as the first entry. Makes the graph prettier
      loginData.unshift([loginData[0][0], 0])

      # Make sure that last values on both lines are on the same date. Just
      # duplicate the last value from each line. Otherwise we'll see some
      # glitches in graphs
      if _.last(loginData)[0] < _.last(powerData)[0]
        loginData.push([
          _.last(powerData)[0] # Use date from power data
          _.last(loginData)[1] # duplicate last value
        ])
      if _.last(loginData)[0] > _.last(powerData)[0]
        powerData.push([
          _.last(loginData)[0] # use date from login data
          _.last(powerData)[1] # duplicate last value
        ])

      graph = Flotr.draw(@el, [
        {
          data: powerData
          color: "#ff9e00"
          lines: {
            fill: true
            steps: true
          }
        },
        {
          data: loginData
          color: "#804f00"
          lines: {
            fill: true
            steps: true
          }
        }
      ], {
        xaxis: {
          title: "Time"
          mode: "time"
        }
        yaxis: {
          title: "Machines"
          tickDecimals: 0
        }
      })

