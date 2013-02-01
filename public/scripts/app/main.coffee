define [
  "jquery"
  "underscore"
  "backbone"
  "uri"
  "socket.io"
  "cs!app/handlebarshelpers"
  "cs!app/logrouter"
  "cs!app/models/wlanhostmodel"
  "cs!app/models/schoolmodel"
  "cs!app/models/wlanclientcollection"
  "cs!app/views/lightbox"
  "cs!app/views/mainlayout"
  "cs!app/url"
], (
  $
  _
  Backbone
  URI
  io
  __
  LogRouter
  WlanHostModel
  SchoolModel
  WlanClientCollection
  Lightbox
  MainLayout
  url
) -> $ ->

  schoolModel = new SchoolModel
    name: url.currentOrg

  $.get "/schools/#{ url.currentOrg }", (schools, status, res) =>
    if status isnt "success"
      console.error "failed to fetch school list", res
      throw new Error "failed to fetch school list"

    schoolName = schools[url.currentSchoolId]
    title = "Wlan usage in #{ schoolName } of #{ url.currentOrg }"
    $("title").text title

    schoolModel.set
      otherSchools: schools
      schoolName: schoolName
      title: title

  loading = $(".loading")

  clients = new WlanClientCollection
  hosts = new Backbone.Collection

  logRouter = new LogRouter
    clients: clients
    hosts: hosts
    school: schoolModel

  historySize = URI(window.location.href).query(true)?.events || 2000

  loading.text "Loading #{ historySize } entries from history..."
  $.get "/log/#{ url.currentOrg }/wlan", {
    limit: historySize
    match: {
      school_id: url.currentSchoolId
    }
  }, (logArr, status, res) ->

    if status isnt "success"
      console.info "failed to fetch previous log data", res
      throw new Error "failed to fetch previous log data"

    console.info "Loaded #{ logArr.length } entries from db"

    loading.text "Updating models..."
    for packet in logArr
      logRouter.handle packet

    layout = new MainLayout
      clients: clients
      hosts: hosts
      model: schoolModel

    layout.render()
    # Cool startup animation
    layout.animateAll()

    $("body").append layout.el

    console.info "Render complete"

    loading.text "Connecting to real time events..."

    Backbone.history.start
      pushState: true
      root: url.appRoot

    socket = io.connect()

    socket.on "packet", (packet) ->
      console.log "got packet", packet
      logRouter.handle packet

    socket.on "connect", ->
      loading.remove()
      socket.emit "join", "log:#{ url.currentOrg }:wlan"
      console.info "Connected to websocket server. All ready."



