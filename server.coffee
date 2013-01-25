

fs = require "fs"
http = require "http"

express = require "express"
io = require "socket.io"
stylus = require "stylus"
engines = require "consolidate"
_  = require "underscore"

clim = require "clim"
_write = clim.logWrite
clim.logWrite = (level, prefixes, msg) ->
  return if level is "LOG" and process.env.NODE_ENV is "production"
  _write(level, prefixes, msg)
clim(console, true)


config = require "./config.json"
Puavo = require "./lib/puavo"

db = require "./lib/db"

app = express()
httpServer = http.createServer(app)
sio = io.listen httpServer
puavo = new Puavo config

appLoad = "start"
app.configure "production", ->
  appLoad = "bundle"

app.configure "development", ->
  app.use stylus.middleware __dirname + "/public"

app.configure ->
  sio.set('log level', 1)
  app.use express.bodyParser()
  app.use express.static __dirname + "/public"
  app.use require "./lib/parsebasicauth"

  app.engine "html", engines.underscore
  app.set "views", __dirname + "/views"
  app.set "view engine", "html"

app.get "/", (req, res) ->
  res.send "And your organisation is?"

app.get "/:org/:schoolId/wlan*", (req, res) ->
  res.render "wlan", appLoad: appLoad

app.get "/:org", (req, res) ->
  res.render "orgindex", appLoad: appLoad

app.get "/schools/:org", require("./routes/schools")(db)

app.get "/desktop/:organisation/widget/:widget", (req, res) ->
  res.render "widget",
    appLoad: appLoad
    name: req.params.widget

app.use "/api/desktop", require("./routes/desktop")(db)


app.get "/log/:org/:schoolId/:type", require("./routes/log_history")(db)
app.post "/log", require("./routes/log")(db, sio, puavo)

puavo.on "ready", ->
  httpServer.listen 8080, ->
    console.info "Server is listening on 8080"

logUsers = (room) ->
  userCount = sio.sockets.manager.rooms["/" + room].length
  console.info "There are now #{ userCount} users in room #{ room }"

sio.sockets.on "connection", (socket) ->
  socket.on "join", (room) ->
    socket.join(room)
    console.info "Socket joined to", room
    logUsers(room)

    socket.on "disconnect",  ->
      console.info "Socket disconnected from", room
      logUsers(room)

puavo.pollStart()
