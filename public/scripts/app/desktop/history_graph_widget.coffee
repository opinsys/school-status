###*
# @exports {Function} createHistoryGraphView
#   @param {String} organisation
#   @param {Socket} socket Socket.IO socket object
###
define [
  "moment"

  "cs!app/desktop/history_graph_view"
  "cs!app/desktop/history_graph_model"
], (
  moment

  HistoryGraphView
  HistoryGraphModel
) -> (organisation, socket) ->

  morning = moment().startOf('day').add(hours: 5).unix()*1000

  history = new HistoryGraphModel(null, {
    organisation: organisation
    query: {
      after: morning
    }
  })

  widget = new HistoryGraphView
    model: history

  history.fetch()

  return widget
