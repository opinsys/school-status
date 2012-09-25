

fs = require "fs"
domain = require "domain"
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

# Object of log handlers for different types of events. Can be used to
# manipulate log data or to add hooks.
# TODO: support multiple handlers per event type
logHandlers =
  default: (data, meta, cb) -> cb null, data
  get: (type) -> this[type] or this.default

  wlan: require("./loghandlers/wlan")(puavo)
  # desktop: require("./loghandlers/desktop")(options...)
  # laptop: require("./loghandlers/laptop")(options...)


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

# Return all schools in given organisation
app.get "/schools/:org", (req, res) ->
  org = req.params.org

  # At this point we have only wlan collection so we use it.
  collName = "log:#{ org }:wlan"
  coll = db.collection collName

  schools = {}

  # XXX: This will go through almost all entries in given organisation. We
  # might want to optimize this with distinct&find combo if would become too
  # slow
  coll.find({
    school_id: { $exists: true }
  }, {
    school_id: 1
    school_name: 1
  }).forEach (doc) ->

    if doc.school_id
      schools[doc.school_id] = doc.school_name

  , (err) ->
    return res.send err, 501 if err
    res.json schools


# GET log history
# @query {Integer} limit
app.get "/log/:org/:schoolId/:type", (req, res) ->

  org = req.params.org
  type = req.params.type
  schoolId = parseInt(req.params.schoolId, 10)
  limit = req.query.limit or 10

  collName = "log:#{ org }:#{ type }"
  coll = db.collection collName

  # Find latest entries
  coll.find(school_id: schoolId).sort({ relay_timestamp: -1 }).limit(limit).toArray (err, arr) ->
    if err
      console.info "Failed to fetch #{ collName }"
      return res.send err, 501


    # Send latest event as last
    arr.reverse()

    for doc in arr
      delete doc._id

    console.info "Fetch #{ arr.length } items from #{ collName }"
    res.json arr




# Logs any given POST data to given MongoDB collection.
app.post "/log", (req, res) ->

  d = domain.create()
  d.on "error", (err) ->
    console.error "Failed to save log data"
    console.error err.stack

  d.run -> process.nextTick ->

    # Just respond immediately to sender. We will just log database errors.
    res.json message: "thanks"

    data = req.body
    fullOrg = data.relay_puavo_domain

    if match = data.relay_puavo_domain.match(/^([^\.]+)/)
      org = match[1]
    else
      console.error "Failed to parse organisation key from '#{ data.relay_puavo_domain }'. Ignoring packet."
      return

    puavo.authentication org, req.auth, (err, status) ->
      throw err if err

      if not status
        console.info "Failed authenticate #{ req.auth.username }. Ignoring packet"
        return

      if not data.type or data.type is "unknown"
        data.type = "unknown"
        console.error "Unknown type or missing! #{ data.type }"

      collName = "log:#{ org }:#{ data.type }"
      coll = db.collection collName

      handler = logHandlers.get(data.type)

      meta =
        org: org
        db: db
        coll: coll
        collName: collName

      handler data, meta, (err, data) ->
        throw err if err

        # Packet ignored by log handler
        return if not data

        # Send to browser clients
        sio.sockets.emit collName, data

        # Save to database
        coll.insert data, (err, docs) ->
          throw err if err
          console.info "Log saved to #{ org }/#{ collName }"



puavo.on "ready", ->
  httpServer.listen 8080, ->
    console.info "Server is listening on 8080"

puavo.pollStart()
