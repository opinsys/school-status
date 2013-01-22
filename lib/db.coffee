
Mongolian = require "mongolian"
mongo = new Mongolian

config = require "../config.json"
module.exports = db = mongo.db config.dbName || "ltsplog"

