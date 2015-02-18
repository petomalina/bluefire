require("should")
Policies = require("../policies")

describe "Policies", () ->

  describe "Policy Manager", () ->
    manager = null

    it "should construct policy manager", () ->
      manager = new Policies.Manager