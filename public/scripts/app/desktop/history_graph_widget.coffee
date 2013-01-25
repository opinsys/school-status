###*
# @exports {Function} createHistoryGraphView
#   @param {String} organisation
#   @param {Socket} socket Socket.IO socket object
###
define [
  "cs!app/desktop/history_graph_view"
], (
  HistoryGraphView
) -> (organisation, socket) ->

  history = new HistoryGraphView

  return history
