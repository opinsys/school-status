define [
  "jquery"
  "underscore"
  "socket.io"

  "cs!app/desktop/summary_widget"
  "cs!app/desktop/history_graph_widget"
  "cs!app/desktop/iframe_info_view"
], (
  $
  _
  io

  createSummaryWidget
  createHistoryGraphView
  IframeInfoView
) -> $ ->

  urlMatch = window.location.toString().match(/\/desktop\/(\w+)\/widget\/(\w+)/)
  if not urlMatch
    throw new Error "Bad url! #{ window.location }"

  organisation = urlMatch[1]
  widgetName = urlMatch[2]

  $("title").text("Desktop statistics for #{ organisation }")

  socket = io.connect()
  socket.on "connect", (c) ->
    socket.emit "join", "log:#{ organisation }:desktop"

  widget =
    switch widgetName
      when "summary"
        createSummaryWidget(organisation, socket)
      when "historygraph"
        createHistoryGraphView(organisation, socket)
      else
        throw new Error "Unkown widget '#{ widgetName }'"

  widget.render()
  $(".widget-container").html(widget.el)

  if window is window.top
    info = new IframeInfoView url: window.location.toString()
    info.render()
    $("body").append(info.el)
    info.slideUp()
