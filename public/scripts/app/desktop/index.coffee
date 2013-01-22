define [
  "jquery"
  "underscore"

  "hbs!app/desktop/templates/index"
], (
  $
  _

  template
) -> $ ->


  $.ajax({
    url: "/api/desktop/kehitys"
  }).done (data) ->

    summary = {
      poweredOnCount: 0
      loggedInCount: 0
      total: 0
    }

    _.each _.values(data), (machine) ->

      if machine.powerOn
        summary.poweredOnCount += 1

      if machine.loggedIn
        summary.loggedInCount += 1

      summary.total += 1

    $("body").html(template(summary))
    $("title").text($("h1").text())
