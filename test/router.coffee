require("should")
Router = require("../routing").Router

describe "Router", () ->
  
  it "should construct router correctly", () ->
    router = new Router
    (router?).should.be.true
    router.paths.should.be.eql({}) # router should be empty after construction
    router.controllers.should.be.eql({})
    
  it "should add controller into the router", () ->
    router = new Router
    
    # pass constructor into the controller
    router.controller "ctrl", class MyCtrl
      constructor: () ->
        
      path: (session, data) ->
        session.nothing.should.be.eql(false)
    
    (router.controllers["ctrl"]?).should.be.true
    router.controllers["ctrl"].path({nothing: false})
    
  it "should add path without controller into router", () ->
    router = new Router
    
    router.route "packet", (session, data) ->
      session.nothing.should.be.eql(false)
      
    (router.paths["packet"]?).should.be.true
    router.paths.packet.action({nothing: false})
    
  it "should add controller and it's path into router and call it", (done) ->
    router = new Router
    
    router.controller "ctrl", class Ctrl
    
      constructor: () ->
        
      myAction: (session, data) ->
        session.nothing.should.be.eql(false)
        done()
        
    router.route("packet", "myAction", "ctrl")
    
    router.call("packet", {nothing: false}, {})