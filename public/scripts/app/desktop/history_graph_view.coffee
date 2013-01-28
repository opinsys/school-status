define [
  "backbone"
  "backbone.viewmaster"
  "rickshaw"

  "hbs!app/desktop/templates/history_graph"
], (
  Backbone
  ViewMaster
  Rickshaw

  template
) ->



  class HistoryGraphView extends ViewMaster

    constructor: ->
      super
      @listenTo @model, "change sync", @render

    template: template

    render: ->
      super

      powerData = _.map @model.get("power"), (entry) ->
        return {
          x: entry.date
          y: entry.count
        }

      if powerData.length is 0
        return

      loginData = _.map @model.get("login"), (entry) ->
        return {
          x: entry.date
          y: entry.count
        }

      graph = new Rickshaw.Graph( {
        element: document.getElementById("chart"),
        width: 960,
        height: 500,
        renderer: 'line',
        series: [
          {
            color: "#c05020",
            data: powerData,
            name: 'Powered on devices'
          },
          {
            color: "#ff560c",
            data: loginData,
            name: 'Devices in use'
          }
        ]
      })

      graph.render()

      hoverDetail = new Rickshaw.Graph.HoverDetail( {
        graph: graph
      })

      legend = new Rickshaw.Graph.Legend( {
        graph: graph,
        element: document.getElementById('legend')

      })

      shelving = new Rickshaw.Graph.Behavior.Series.Toggle( {
        graph: graph,
        legend: legend
      })

      axes = new Rickshaw.Graph.Axis.Time( {
        graph: graph
      })
      axes.render()
