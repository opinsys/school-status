define [
  "underscore"
  "backbone"
  "backbone.viewmaster"
  "flotr2"

  "hbs!app/desktop/templates/history_graph"
], (
  _
  Backbone
  ViewMaster
  Flotr

  template
) ->

  class HistoryGraphView extends ViewMaster

    className: "bb-history-graph"

    powerColor: "#ff9e00"
    loginColor: "#804f00"

    constructor: ->
      super
      @listenTo @model, "change sync", @render
      $(window).on "resize", _.debounce =>
        @render()
      , 500

    template: template

    elements: {
      "$plot": ".plot"
      "$power": ".power"
      "$login": ".login"
    }

    render: ->
      super
      @$power.css("color", @powerColor)
      @$login.css("color", @loginColor)

      @$(".plot").width($(window).width() - 50)
      @$(".plot").height($(window).height() - 100)

      powerData = _.uniq @model.get("power")
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

      flotrData = [
        {
          data: powerData
          color: @powerColor
          lines: {
            fill: true
            steps: true
          }
        },
        {
          data: loginData
          color: @loginColor
          lines: {
            fill: true
            steps: true
          }
        }
      ]

      flotrOptions = {
        HtmlText: false
        xaxis: {
          title: "Time"
          mode: "time"
        },
        yaxis: {
          title: "Machines"
          tickDecimals: 0
        }
      }

      graph = Flotr.draw(@$plot.get(0), flotrData, flotrOptions)
