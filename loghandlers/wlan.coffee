
oui = require "../lib/oui"

module.exports = (puavo) -> (data, meta, cb) ->

  if not data.mac
    console.error "Ignoring wlan packet. 'mac' missing", data
    return cb()

  if not data.hostname
    console.error "Ignoring wlan packet. 'hostname' missing", data
    return cb()

  data.client_hostname = puavo.lookupDeviceName(meta.org, data.mac)

  data.client_manufacturer = oui.lookup data.mac

  if data.school_id = puavo.lookupSchoolId(meta.org, data.hostname)
    data.school_name = puavo.lookupSchoolName(meta.org, data.school_id)
    return cb null, data

   return cb new Error "Cannot find school for #{ meta.org }/#{ data.hostname }"
