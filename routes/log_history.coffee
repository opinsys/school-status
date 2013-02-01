_ = require "underscore"

###*
# GET /log/:organisation/:type
# Get log entries.
#
# :organisation is an organisation name. eg. 'jyvaskyla'
# :id event log type. Eg. 'wlan', 'desktop'
#
# @query querystring
#   @param {Number} limit
#     Limit document count. Default 1000
#   @param {Number} after
#     Return only the documents created after this unix timestamps
#   @param {Number} before
#     Return only the documents created before this unix timestamps
#   @param {Array} projection
#     Filter returned fields.
#   @param {Object} match
#     Return only matched documents
# @return {Array} logdocuments
#
# Pro tip: Use jQuery.param(...) to build the query string
#
###
module.exports = (db) -> (req, res) ->

  organisation = req.params.organisation
  eventtype = req.params.eventtype
  schoolId = parseInt(req.params.schoolId, 10)

  limit = req.query.limit or 1000
  query = {}
  projection = {}

  if req.query.projection
    for key in req.query.projection
      projection[key] = true

  if req.query.match
    for k, v of req.query.match
      if v[0] is "$"
        return res.json 501, error:
          msg: "queries with $ are not implemented"

      if v.match(/^[0-9]+$/)
        v = parseInt(v, 10)
      query[k] = v

  if req.query.after
    query.date ?= {}
    query.date.$gte = parseInt(req.query.after, 10)

  if req.query.before
    query.date ?= {}
    query.date.$lt = parseInt(req.query.before, 10)

  collName = "log:#{ organisation }:#{ eventtype }"
  coll = db.collection collName

  start = Date.now()
  console.log "GET wth", query, limit
  coll
    .find(query, projection)
    .sort({ relay_timestamp: -1 })
    .limit(limit)
    .toArray (err, arr) ->
      if err
        console.info "Failed to fetch #{ collName }"
        return res.json 501, err

      # Send latest event as last
      arr.reverse()

      console.info "Fetched #{ arr.length } items from #{ collName } in #{ Date.now() - start }ms"
      res.json arr
