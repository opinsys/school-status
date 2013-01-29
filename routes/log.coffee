
async = require "async"

# Logs any given POST data to given MongoDB collection.
module.exports = (db, sio, puavo) ->

  ###*
  # Add school information to a logrelay packet
  #
  # @param {Object} meta Metadata about the packet. MongoDB instance etc.
  # @param {Object} data The log packet
  # @param {Function} cb Callback
  #   @param {Error} cb.err possbile error object or null
  #   @param {Object} cb.meta
  #   @param {Object} cb.data Data with added school infromation
  ###
  addSchool = (meta, data, cb) ->
    if not data.hostname
      console.error "Packet is missing hostname. Cannot find schoold id&name for it"
      return cb null, meta, data

    id = puavo.lookupSchoolId(meta.org, data.hostname)
    if not id
      console.error "Cannot find school id for '#{ data.hostname }'"
      return cb null, meta, data

    name = puavo.lookupSchoolName(meta.org, id)
    if not name
      console.error "Cannot find school name for id '#{ id }'"
      return cb null, meta, data

    data.school_id = id
    data.school_name = name
    return cb null, meta, data


  # Object of log handlers for different types of events. Can be used to
  # manipulate log data or to add hooks.
  # TODO: support multiple handlers per event type
  logHandlers =
    wlan: require("../loghandlers/wlan")(puavo)
    # desktop: require("../loghandlers/desktop")(options...)
    # laptop: require("../loghandlers/laptop")(options...)


  return (req, res) ->

    # Just respond immediately to sender. We will just log database errors.
    res.json message: "thanks"

    data = req.body
    console.log "http got packet", data
    fullOrg = data.relay_puavo_domain

    if data.date
      data.date = parseInt(data.date, 10)

    # All characters before the first dot
    if match = data.relay_puavo_domain.match(/^([^\.]+)/)
      org = match[1]
    else
      console.error "Failed to parse organisation key from '#{ data.relay_puavo_domain }'. Ignoring packet."
      return

    puavo.authentication org, req.auth, (err, status) ->
      if err
        console.error "Authentication error", err
        return

      if not status
        console.info "Bad credentials for #{ req.auth?.username }. Ignoring packet."
        return

      if not data.type
        console.error "Packet type missing!", data

      collName = "log:#{ org }:#{ data.type }"
      coll = db.collection collName

      meta =
        org: org
        db: db
        coll: coll
        collName: collName

      async.waterfall [
        (cb) -> cb null, meta, data # inject meta&data into waterfall
        addSchool
        logHandlers[data.type] or (meta, data, cb) -> cb null, meta, data
      ], (err, meta, data) ->

        if err
          console.error "Log handler failed on packet", packet, err
          return

        # Packet ignored by log handler
        return if not data

        # Send to browser clients
        sio.sockets.in(collName).emit "packet", data

        # Save to database
        coll.insert data, (err, docs) ->
          if err
            console.error "Data insertion to mongo failed", err
          else
            console.log "saved", docs

