

# Return all schools in given organisation as json
module.exports = (db) -> (req, res) ->
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
