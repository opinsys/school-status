define [
  "backbone"
  "backbone.viewmaster"

  "hbs!app/desktop/templates/summary"
], (
  Backbone
  ViewMaster

  template
) ->

  class SummaryView extends ViewMaster

    className: "bb-summary-view"
    template: template

    constructor: ->
      super
      @listenTo @model, "change sync", @animateAndRender

    animateAndRender: ->
      @$("div").addClass("animated tada")
      setTimeout =>
        @render()
        @$("div").removeClass("animated tada")
      , 1300

    context: -> {
      poweredOnCount: _.last(@model.get("power"))?.count or 0
      loggedInCount: _.last(@model.get("login"))?.count or 0
    }
