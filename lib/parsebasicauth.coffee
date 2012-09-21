
module.exports = (req, res, next) ->

  if not req.headers.authorization
    return next()

  try
    data = req.headers.authorization.split(" ")[1]
    [username, password] = new Buffer(data, "base64").toString().split(":")
  catch e
    err = new Error "failed to parser basic auth"
    err.orginalError = e
    return next err

  req.auth =
    username: username
    password: password

  return next()
