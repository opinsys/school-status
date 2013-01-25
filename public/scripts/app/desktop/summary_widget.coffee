###*
# @exports {Function} createSummaryWidget
#   @param {String} organisation
#   @param {Socket} socket Socket.IO socket object
###
define [
  "cs!app/desktop/desktop_model"
  "cs!app/desktop/summary_view"
], (
  DesktopModel
  SummaryView
) -> (organisation, socket) ->

  sm = new DesktopModel null, organisation: organisation
  summary = new SummaryView model: sm
  sm.fetch()

  socket.on "packet", (packet) ->
    sm.fetch()

  return summary
