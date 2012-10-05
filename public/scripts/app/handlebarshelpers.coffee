define [
  "cs!app/url"
  "handlebars"
], (
  url
  Handlebars
) ->

  Handlebars.registerHelper "hostLink", (id) ->
    "#{ url.appRoot }host/#{ id }"

  Handlebars.registerHelper "clientLink", (id) ->
    "#{ url.appRoot }client/#{ id }"

  return null
