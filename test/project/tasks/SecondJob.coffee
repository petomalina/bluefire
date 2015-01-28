module.exports = {

  options: {
    timeout: 1
    repeat: true
    repeatTimes: 5
  }

  action: (context) ->
    context.argument++
}