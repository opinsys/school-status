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


      console.log(
        "frame",
        new Date(_.first(powerData).date),
        new Date(_.last(powerData).date)
      )

      powerData = _.map powerData, (entry) ->
        [entry.date, entry.count]

      loginData = _.map @model.get("login"), (entry) ->
        [entry.date, entry.count]

      graph = Flotr.draw(@el, [
        {
          data: powerData
          color: "#ff9e00"
          lines: {
            fill: true
          }
        },
        {
          data: loginData
          color: "#804f00"
          lines: {
            fill: true
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

