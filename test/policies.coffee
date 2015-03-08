require("should")
Policies = require("../policies")

describe "Policies", () ->

  describe "Policy Manager", () ->
    manager = null

    it "should construct policy manager", () ->
      manager = new Policies.Manager
      
    it "should try to add policy", (done) ->
      manager.policy "auth", (session, data, next) ->
        if session.auth is true
          next()
          
      manager.get("auth")({ auth: true}, {}, done)