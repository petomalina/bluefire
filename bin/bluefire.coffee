Git = require("machinepack-git")

###
  Parses given array of input arguments and recognizes commands,
  subcommands and switches with their values

  @param [argv] argument list to parse
  @return [ Array, Object] An array of commands and object of switches
###
parseArguments = (argv) ->
  commands = []
  switches = { }

  for y in [0...argv.length]
    break if argv[y].trim()[0] is '-' # commands are till first switch
    commands.push(argv[y].trim())

  skip = false # skip the value if it belongs to switch
  for i in [y...argv.length]
    if skip
      skip = false
      continue

    if i + 1 < argv.length and argv[i+1].trim()[0] isnt '-'
      switches[argv[i]] = argv[i+1] # assign value to the given switch
      skip = true
    else
      switches[argv[i]] = null # switch has no value, give it null

  return [ commands, switches ]

FileSystem = require("fs")

path = process.cwd() # get path
[ commands, switches ] = parseArguments(process.argv.slice(2)) # get argument map

commandTable = {
  'new' : (commands, switches) ->
    name = commands[0] # first in commands is name of the app
    projectPath = "#{path}/#{name}"
    console.log(">> Creating bluefire applicaiton inside #{projectPath}")

    if FileSystem.existsSync(projectPath) is true
      console.log(">> Given folder already exists!")
      return

    Git.clone({
      dir: projectPath
      remote: 'https://github.com/Gelidus/bluefire-generated-project.git'
    }).exec({
      error: (err) ->
        console.log(">> We could not fetch the data from server #{err}")

      success: (result) ->
        console.log ">> Your project was successfully generated"
    })
}

call = (currentCommand) ->
  if commandTable[commands[currentCommand]]?
    commandTable[commands[currentCommand]](commands.splice(currentCommand+1), switches)
  else
    console.log(">> Sorry, no command found named \"#{commands[currentCommand]}\"")

call(0) # call with first command