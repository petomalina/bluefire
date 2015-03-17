
module.exports = class MyPolicy

  default: (session, data, next) =>
    if data.password is "pass"
      session.authenticated = true # authenticate session
      next()