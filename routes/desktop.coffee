

express = require "express"

{ parseSummary,
  parseMachineDetails } = require("../lib/desktop_parsers")

app = express()

module.exports = (db) ->

  addCollection = (req, res, next) ->
    req.collection = db.collection("log:#{ req.params.organisation }:desktop")
    next()

  app.get "/:organisation", addCollection, (req, res) ->

    parseSummary req.collection, (err, results) ->
      if err
        res.json 500, err
      else
        res.json results

  app.get "/:organisation/:hostname", addCollection, (req, res) ->

    parseMachineDetails req.collection, req.params.hostname, (err, results) ->
      if err
        res.json 500, err
      else
        res.json results

  return app

