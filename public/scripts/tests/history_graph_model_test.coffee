define [
  "cs!app/desktop/history_graph_model"
], (
  HistoryGraphModel
) ->

  describe "HistoryGraphModel", ->
    model = null
    beforeEach ->
      model = new HistoryGraphModel null,
        organisation: "testorg"

    it "pushes 'bootend' events to power attribute", ->
      date = Date.now()

      model.parse([{
          date: date
          hostname: "foo"
          event: "bootend"
      }])

      expect(model.get("power")).to.deep.eq([{
        date: date
        count: 1
      }])

    it "ignores 'shutdown' events before 'bootend'", ->
      model.parse([{
          hostname: "foo"
          event: "shutdown"
      }])
      expect(model.get("power").length).to.eq 0
      expect(model.get("login").length).to.eq 0

    it "ignores 'logout' events before 'login'", ->
      model.parse([{
          hostname: "foo"
          event: "logout"
      }])
      expect(model.get("login").length).to.eq 0

    it "'logout' events get added after a 'login event", ->
      model.parse([
        {
          hostname: "foo"
          event: "login"
        },
        {
          hostname: "foo"
          event: "logout"
        }
      ])
      expect(model.get("login").length).to.eq 2

    it "pushes shutdown events to 'power' after 'bootend'", ->
        model.parse([
          {
            hostname: "foo"
            event: "bootend"
          },
          {
            hostname: "foo"
            event: "shutdown"
          }
        ])
        expect(model.get("power").length).to.eq 2


    it "login event at begining creates implicit 'bootend'", ->
      date = Date.now()

      model.parse([{
        date: date
        hostname: "foo"
        event: "login"
      }])

      expect(model.get("power")[0]).to.deep.eq({
        date: date
        count: 1
      })


