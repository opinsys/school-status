define [
  "backbone"
], (
  Backbone
) ->

  ###*
  # Desktop model holding statistics about desktop state and individual
  # machines
  #
  # @property {Collection} machines Collection of individual machines
  ###
  class DesktopModel extends Backbone.Model

    defaults:
      poweredOnCount: 0
      loggedInCount: 0
      total: 0

    constructor: (attrs, options) ->
      super
      @url = "/api/desktop/#{ options.organisation }"
      @machines = new Backbone.Collection

    parse: (data, xhr) ->

      summary = _.clone(@defaults)

      _.each _.values(data), (machine) =>
        @machines.add new Backbone.Model machine

        if machine.powerOn
          summary.poweredOnCount += 1
        if machine.loggedIn
          summary.loggedInCount += 1
        summary.total += 1

      return summary
