define [
  "jquery"
  "underscore"
  "socket.io"
  "backbone"

  "cs!app/desktop/desktop_model"
  "cs!app/desktop/summary_view"
], (
  $
  _
  io
  Backbone

  DesktopModel
  SummaryView
) -> $ ->

  urlMatch = window.location.toString().match(/\/desktop\/(\w+)/)
  if not urlMatch
    throw new Error "Bad url! #{ window.location }"
  organisation = urlMatch[1]

  $("title").text("Desktop statistics for #{ organisation }")


  sm = new DesktopModel null, organisation: organisation
  summary = new SummaryView model: sm

  $("body").html(summary.el)

  sm.fetch()

  socket = io.connect()
  socket.on "connect", (c) ->
    socket.emit "join", "log:#{ organisation }:desktop"
  socket.on "packet", (packet) ->
    sm.fetch()
