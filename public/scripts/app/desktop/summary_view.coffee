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
      @listenTo @model, "change", @render

    render: ->
      @$el.html(template(@model.toJSON()))

