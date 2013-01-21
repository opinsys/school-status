
_ = require "underscore"

###*
# Generate nice statistics from desktop boot and login log data
###
module.exports = (db) -> (req, res) ->

  org = req.params.org
  search = req.query.search

  collName = "log:#{ org }:desktop"
  coll = db.collection collName

  machines =
    details: {}
    poweredOn: 0
    loggedIn: 0


  coll.find(search).sort({ relay_timestamp: -1 }).forEach (doc) ->

    out = machines.details[doc.hostname] ?= { events: [] }

    out = _.extend(out, _.pick(
      doc
      "hostname"
      "devices"
      "school_id"
      "school_name"
      "relay_hostname"
      "relay_puavo_domain"
    ))

    out.events.unshift(_.pick(
      doc
      "date"
      "event"
    ))

  , (err) ->
    if err
      return res.json err

    machines.total = _.size(machines.details)

    _.each _.values(machines.details), (machine) ->

      if _.last(machine.events).event isnt "shutdown"
        machines.poweredOn += 1

      if _.last(machine.events).event is "login"
        machines.loggedIn += 1

    res.json machines



