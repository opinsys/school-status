define [
  "cs!app/models/wlanhostmodel"
  "cs!app/views/layout"
  "cs!app/views/wlanstats"
  "cs!app/views/totalstats"
  "cs!app/views/schoolselect"
  "cs!app/router"
  "backbone"
  "underscore"
], (
  WlanHostModel
  Layout
  WlanStats
  TotalStats
  SchoolSelect
  Router
  Backbone
  _
) ->

  class MainLayout extends Layout

    className: "bb-wlan-layout"
    templateQuery: "#wlan-layout"


    constructor: ({@hosts, @clients}) ->
      super

      @router = new Router
        clients: @clients
        hosts: @hosts

      @subViews =
        ".total-stats-container": new TotalStats
          model: @model
          clients: @clients
          hosts: @hosts
        ".school-select-container": new SchoolSelect
          model: @model
        ".wlan-hosts": []

      @hosts.each (model) => @_addViewForHost model

      @model.on "change:title", => @render()
      @hosts.on "add", (model) =>
        @_addViewForHost model
        @render()

    _addViewForHost: (model) ->
        view = new WlanStats
          model: model
          collection: @clients
        @subViews[".wlan-hosts"].push view

    animateAll: ->
      for view in @subViews[".wlan-hosts"]
        view.animate()


    viewJSON: ->
      schoolName: @model.get "schoolName"
      title: @model.get "title"




