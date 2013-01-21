

fs = require "fs"
http = require "http"

express = require "express"
io = require "socket.io"
stylus = require "stylus"
Mongolian = require "mongolian"
engines = require "consolidate"
_  = require "underscore"

config = require "./config.json"
Puavo = require "./lib/puavo"

mongo = new Mongolian
app = express()
httpServer = http.createServer(app)
db = mongo.db "ltsplog"
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
app.get "/desktops/:org", require("./routes/desktops")(db)
app.get "/log/:org/:schoolId/:type", require("./routes/log_history")(db)
app.post "/log", require("./routes/log")(db, sio, puavo)

puavo.on "ready", ->
  httpServer.listen 8080, ->
    console.info "Server is listening on 8080"

puavo.pollStart()
