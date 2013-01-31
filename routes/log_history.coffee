_ = require "underscore"

# @url {GET} /log/:organisation/:eventtype
# @query {Integer} _limit result limit
# @query {*} [*] Zero or more query filters
# @return {Array} logentries
module.exports = (db) -> (req, res) ->

  organisation = req.params.organisation
  eventtype = req.params.eventtype
  schoolId = parseInt(req.params.schoolId, 10)

  limit = req.query._limit or 1000
  search = {}
  projection = {}
  if req.query.projection
    for key in req.query.projection
      projection[key] = true

  if req.query.after
    search.date ?= {}
    search.date.$gte = parseInt(req.query.after, 10)

  if req.query.before
    search.date ?= {}
    search.date.$lt = parseInt(req.query.before, 10)

  collName = "log:#{ organisation }:#{ eventtype }"
  coll = db.collection collName

  start = Date.now()
  # Find latest entries
  coll.find(search, projection).sort({ relay_timestamp: -1 }).limit(limit).toArray (err, arr) ->
    if err
      console.info "Failed to fetch #{ collName }"
      return res.send err, 501

    # Send latest event as last
    arr.reverse()

    for doc in arr
      delete doc._id

    console.info "Fetched #{ arr.length } items from #{ collName } in #{ Date.now() - start }ms"
    res.json arr
