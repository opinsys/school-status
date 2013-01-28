###*
# @exports {Function} createHistoryGraphView
#   @param {String} organisation
#   @param {Socket} socket Socket.IO socket object
###
define [
  "cs!app/desktop/history_graph_view"
  "cs!app/desktop/history_graph_model"
], (
  HistoryGraphView
  HistoryGraphModel
) -> (organisation, socket) ->

  window.history = new HistoryGraphModel null,
    organisation: organisation

  widget = new HistoryGraphView
    model: history

  history.fetch()

  return widget
