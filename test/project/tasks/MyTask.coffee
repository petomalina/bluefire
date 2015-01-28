module.exports = {

  options: {
    timeout: 1
    repeat: false
  }

  action: (context) ->
    context.method()
}