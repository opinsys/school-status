
_ = require "underscore"

###*
# Generate nice statistics from desktop boot and login log data
###
module.exports = (db) -> (req, res) ->

  org = req.params.org
  search = req.query.search

  collName = "log:#{ org }:desktop"
  coll = db.collection collName

  machines = {}

  coll.find(search).sort({ relay_timestamp: -1 }).forEach (doc) ->

    out = machines[doc.hostname] ?= { events: [] }

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
    res.json machines



