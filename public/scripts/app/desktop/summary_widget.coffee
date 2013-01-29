###*
# @exports {Function} createSummaryWidget
#   @param {String} organisation
#   @param {Socket} socket Socket.IO socket object
###
define [
  "cs!app/desktop/history_graph_model"
  "cs!app/desktop/summary_view"
], (
  HistoryGraphModel
  SummaryView
) -> (organisation, socket) ->

  history = new HistoryGraphModel null,
    organisation: organisation

  summary = new SummaryView model: history

  history.fetch()

  socket.on "packet", (packet) ->
    history.fetch()

  return summary
