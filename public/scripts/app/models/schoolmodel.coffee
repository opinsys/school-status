define [
  "backbone"
  "underscore"
], (
  Backbone,
  _
) ->

  class SchoolModel extends Backbone.Model

    constructor: ->
      super

    incEventCount: ->
      count = @get("eventCount") or 0
      @set "eventCount", count + 1
