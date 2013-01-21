
oui = require "../lib/oui"

# Handle wlan type packages.
# Add devices hostname and client manufacturer by mac
module.exports = (puavo) -> (meta, data, cb) ->

  # error return
  rerr = (msg) ->
    console.error "Bad wlan packet: #{ msg }"
    cb null, meta, data

  if not data.mac
    return rerr "mac is missing"

  if data.wlan_event isnt "hotspot_state"
    return rerr "'wlan_event' isn't 'hotspot_state'"

  if not data.hostname
    return rerr "'hostname' is missing"

  data.client_hostname = puavo.lookupDeviceName(meta.org, data.mac)
  data.client_manufacturer = oui.lookup(data.mac)
  cb null, meta, data

