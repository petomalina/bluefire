###
  Tests for:
    task/Task
    task/TaskManager

  @version 0.0.3a
###

require("should")
TaskManager = require("../task/TaskManager")

describe "TaskManager", () ->
  manager = null

  describe "#constructor()", () ->
    it "should succesfully construct TaskManager instance", () ->
      manager = new TaskManager
      (manager?).should.be.true
      manager.tasks.should.be.eql({})

  describe "#task()", () ->
    it "should create new task with no options", () ->
      manager.task "MyTask", { }, () ->

    it "should add task and call it", (done) ->
      manager.task "NewTask", { }, () ->
        done()

      manager.perform("NewTask", null)

  describe "#get()", () ->
    it "should try to get two existing tasks", () ->
      myTask = manager.get("MyTask")
      newTask = manager.get("NewTask")

      (myTask?).should.be.true
      (newTask?).should.be.true

    it "should try to get non-existing task", () ->
      task = manager.get("NonExistingTask")
      (task?).should.be.false

  describe "#install()", () ->
    it "should try to install tasks", () ->
      manager.install(null, "#{process.cwd()}/test/project/tasks/")

    it "should check tasks that should not be registered", () ->
      (manager.get(".gitkeep")?).should.be.false # we don't want to register gitkeep
      (manager.get("MyHelper")?).should.be.false

    it "should check for tasks that should be registered", () ->
      (manager.get("MyTask")?).should.be.true
      (manager.get("SecondJob")?).should.be.true

    it "should try to perform task from install", (done) ->
      manager.perform("MyTask", { method: done }) # pass method to the context