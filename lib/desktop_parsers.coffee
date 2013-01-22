###*
# Log parsers for desktop boot and login data
###

_ = require "underscore"

###*
# @param {Object} collection Mongolian database collection
# @param {Function} callback
#   @param {Error} err
#   @param {Object} result
###
parseSummary = (collection, cb) ->

  machines = {}

  collection.find().sort({ relay_timestamp: -1 }).forEach (doc) ->

    machine = machines[doc.hostname] ?= { _events: [] }
    _.extend(machine, _.pick(
      doc
      "school_id"
      "school_name"
    ))
    machine._events.unshift(_.pick(
      doc
      "date"
      "event"
    ))

  , (err) ->
    if err
      return cb err

    _.each _.values(machines), (machine) ->

        lastEvent = _.last(machine._events).event
        machine.powerOn = lastEvent isnt "shutdown"
        machine.loggedIn = lastEvent is "login"
        delete machine._events

    cb null, machines

###*
# @param {Object} collection Mongolian database collection
# @param {Function} callback
#   @param {Error} err
#   @param {Object} result
###
parseMachineDetails = (collection, hostname, cb) ->

  details = events: []

  collection
    .find({ hostname: hostname })
    .sort({ relay_timestamp: -1 })
    .forEach (doc) ->
      _.extend(details, _.pick(
        doc
        "hostname"
        "school_id"
        "school_name"
        "relay_puavo_domain"
        "relay_hostname"
        "devices"
      ))

      details.events.unshift(_.pick(
        doc
        "date"
        "event"
      ))

    , (err) ->
      return cb err if err
      cb null, details

module.exports =
  parseMachineDetails: parseMachineDetails
  parseSummary: parseSummary

if require.main is module
  db = require("./db")

  collection = db.collection("log:kehitys:desktop")

  parseMachineDetails collection, "lucidankka", (err, machine) ->
    console.log err, machine

  parseSummary collection, (err, res) ->
    console.log err, res
