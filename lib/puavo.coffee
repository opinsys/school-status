{EventEmitter} = require "events"
request = require("request")

class Puavo extends EventEmitter

  constructor: (config) ->
    @config = config

    @organisations = config.organisations
    @organisationDevicesByMac = {}
    @organisationSchoolsById = {}
    @organisationDevicesByHostname = {}


  pollStart: ->
    do timeoutLoop = =>
      @poll (err) =>
        @handleStart err
        setTimeout timeoutLoop, @config.refreshDelay


  handleStart: (err) ->
    return if @started
    if not err
      @emit "ready"
    else
      @emit "error", err
    @started = true

  poll: (cb) ->

    requestCount = 0

    for key, value of @organisations then do (key, value) =>

      auth = "Basic " + new Buffer(value["username"] + ":" + value["password"]).toString("base64");

      requestCount += 2
      done = (err) =>
        if err
          done = ->
          return cb err

        requestCount -= 1
        if requestCount is 0
          cb()
          done = ->

      # Get schools
      request {
        url: value["puavoDomain"] + "/users/schools.json",
        headers:  {"Authorization" : auth}
      }, (error, res, body) =>
        if !error && res.statusCode == 200
          schools = JSON.parse(body)
          @organisationSchoolsById[key] = {}
          console.info "Fetched #{ schools.length } schools from #{ value["puavoDomain"] }"
          for school in schools
            @organisationSchoolsById[key][school.puavo_id] = {}
            @organisationSchoolsById[key][school.puavo_id]["name"] = school.name
        else
          console.log("Can't connect to puavo server: ", error)
        done error

      # Get devices
      console.info "Fetcing device list from Puavo #{ value["puavoDomain"] }. This may take some time..."
      request {
        method: 'GET',
        url: value["puavoDomain"] + "/devices/api/v2/devices.json",
        headers:  {"Authorization" : auth}
      }, (error, res, body) =>
        if !error && res.statusCode == 200
          devices = JSON.parse(body)
          @organisationDevicesByMac[key] = {}
          console.info "Fetched #{ devices.length } devices from #{ value["puavoDomain"] }"
          @organisationDevicesByHostname[key] = {}
          for device in devices
            if device.school_id
              @organisationDevicesByHostname[key][ device.hostname ] = {}
              @organisationDevicesByHostname[key][ device.hostname ]["school_id"] = device.school_id
            if device.mac_address
              @organisationDevicesByMac[key][ device.mac_address ] = {}
              @organisationDevicesByMac[key][ device.mac_address ]["hostname"] = device.hostname
        else
          console.log("Can't connect to puavo server: ", error)

        done error

  lookupDeviceName: (org, mac) ->
    @organisationDevicesByMac[org]?[mac]?.hostname

  lookupSchoolName: (org, schoolId) ->
    @organisationSchoolsById[org]?[schoolId]?.name

  lookupSchoolId: (org, deviceHostname) ->
    @organisationDevicesByHostname[org]?[deviceHostname]?.school_id

  authentication: (org, dn, password, cb) ->
    console.log "Authentication"
    auth = "Basic " + new Buffer(dn + ":" + password).toString("base64");
    request {
      method: 'GET',
      url: @organisations[org].puavoDomain + "/devices/auth.json",
      headers:  {"Authorization" : auth}
    }, (err, res, body) ->
      if !err && res.statusCode == 200
        return cb err, JSON.parse(body)
      else
        if err
          console.log "Info: Can't connect to Puavo server: ", err
        return cb err, false
    
  

module.exports = Puavo
