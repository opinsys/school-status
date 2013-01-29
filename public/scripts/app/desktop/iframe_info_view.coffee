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

      @_hide = (e) =>
        if @$el.has(e.target).size() is 0 and @el isnt e.target
          @slideDown()
          $(window).off("click", @_hide)
      $(window).on("click", @_hide)

    slideDown: ->
      @$el.slideUp 400

    elements:
      "$input": "input"

    template: template

    context: -> url: @url

    slideUp: ->
      @$el.slideDown 400, =>
        setTimeout =>
          @$input.get(0).select()
        , 300




