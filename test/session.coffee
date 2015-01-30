require("should")
Session = require("../session")

describe "Session", () ->

  describe "Session Storage", () ->
    store = null

    it "should initialize the storage", () ->
      store = []

    it "should push new session to the store and add id", () ->
      session = new Session
      session.id = 1

      store.push(session)

      store.length.should.be.eql(1)

    it "should push second sesssion to the store", () ->
      session = new Session
      session.id = 2

      store.push(session)

      store.length.should.be.eql(2)

    it "should try to get index of the session on second index", () ->
      find = store[1] # get first
      index = store.indexOf(find)

      index.should.be.eql(1)

    it "should try to find first index",  () ->
      second = store[0]
      index = store.indexOf(second)

      index.should.be.eql(0)

    it "should remove the first and then try to reclaim the first index", () ->
      store.splice(0, 1)
      store.length.should.be.eql(1)

      second = store[0]
      index = store.indexOf(second)

      index.should.be.eql(0)

      store[index].id.should.be.eql(2)