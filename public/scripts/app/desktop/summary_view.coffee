define [
  "backbone"
  "backbone.viewmaster"

  "hbs!app/desktop/templates/index"
], (
  Backbone
  ViewMaster

  template
) ->

  class SummaryView extends ViewMaster

    className: "bb-summary-view"

    constructor: ->
      super
      @listenTo @model, "change", @animateAndRender
      @model.once "change", @render, this

    animateAndRender: ->
      @$("p").addClass("animated tada")
      setTimeout =>
        @render()
        @$("p").removeClass("animated tada")
      , 1300

    render: ->
      @$el.html(template(@model.toJSON()))

