
module.exports = (session, data, next) =>
  if data.password is "pass"
    session.authenticated = true # authenticate session
    next()