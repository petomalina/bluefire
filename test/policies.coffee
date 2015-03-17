require("should")
Policies = require("../policies")

describe "Policies", () ->

  describe "Policy Manager", () ->
    manager = null

    it "should construct policy manager", () ->
      manager = new Policies.Manager
      
    it "should try to add policy", (done) ->
      manager.policy "auth", class MyPolicy

        default: (session, data, next) ->
          if session.auth is true
            next()
          
      manager.get("auth").perform({ auth: true }, {}, done)

  describe "Policy Manager install", () ->
    manager = null

    it "should construct policy manager", () ->
      manager = new Policies.Manager

    it "should try to install policies", (done) ->
      manager.install (err) ->
        done()
      , "#{__dirname}/project/policies/"

    it "should check registered policies", () ->
      (manager.policies["MyPolicy"]?).should.be.true
      (manager.policies["gitkeep"]?).should.be.false
      (manager.policies[".gitkeep"]?).should.be.false

    it "should try to perform policy with bad non auth data", () ->
      session = { }
      manager.perform "MyPolicy", session, {}, () ->
        throw new Error("Policy passed without data")

      (session.authenticated?).should.be.false

    it "should try to perform policy with good auth data", (done) ->
      session = { }
      manager.perform "MyPolicy", session, { password: "pass" }, () ->
        (session.authenticated?).should.be.true
        session.authenticated.should.be.true
        done()

    it "should try to perform non existing policy", (done) ->
      try
        manager.perform "non-existing-policy"
      catch
        done()