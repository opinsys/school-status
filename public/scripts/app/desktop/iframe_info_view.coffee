define [
  "backbone.viewmaster"

  "hbs!app/desktop/templates/iframe_info"
], (
  ViewMaster

  template
) ->
  class IframeInfoView extends ViewMaster

    className: "bb-iframe-info"

    constructor: (options) ->
      super
      @url = options.url
      @$el.hide()

    elements:
      "$input": "input"

    template: template

    context: -> url: @url

    slideUp: ->
      @$el.slideDown 400, =>
        setTimeout =>
          @$input.get(0).select()
        , 300




