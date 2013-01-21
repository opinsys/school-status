
# GET wlan log history
# @query {Integer} limit
module.exports = (db) -> (req, res) ->

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
