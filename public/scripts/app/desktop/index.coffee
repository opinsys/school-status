define [
  "jquery"
  "underscore"
  "socket.io"

  "hbs!app/desktop/templates/index"
], (
  $
  _
  io

  template
) -> $ ->

  urlMatch = window.location.toString().match(/\/desktop\/(\w+)/)
  if not urlMatch
    throw new Error "Bad url! #{ window.location }"
  organisation = urlMatch[1]

  socket = io.connect()
  socket.on "connect", (c) ->
    socket.emit "join", "log:#{ organisation }:desktop"

  socket.on "packet", (packet) ->
    console.log "got packet", packet

  $.ajax({
    url: "/api/desktop/#{ organisation }"
  }).done (data) ->

    summary = {
      poweredOnCount: 0
      loggedInCount: 0
      total: 0
    }

    _.each _.values(data), (machine) ->

      if machine.powerOn
        summary.poweredOnCount += 1

      if machine.loggedIn
        summary.loggedInCount += 1

      summary.total += 1

    $("body").html(template(summary))
    $("title").text($("h1").text())
