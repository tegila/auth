util = require('util')

# route middleware to ensure user is logged in
isLoggedIn = (req, res, next) ->
  console.log "routes.coffee:3 req.cookies = #{util.inspect(req.cookies, false, null)}" 
  if req.isAuthenticated()
    return next()

  res.redirect('/')

module.exports = (app, passport) ->

# normal routes #

  # show the home page (will also have our login links)
  app.get '/', (req, res) ->
    res.render 'index.ejs'

  # PROFILE SECTION =========================
  app.get '/profile', isLoggedIn, (req, res) ->
    res.render 'profile.ejs', { user : req.user }

  # LOGOUT ==============================
  app.get '/logout', (req, res) ->
    do req.logout
    res.redirect('/')


  # locally 
  # show the login form
  app.get '/login', (req, res) ->
    res.render 'login.ejs', { message: req.flash('loginMessage') }

  # process the login form
  app.post '/login', passport.authenticate 'local-login', 
    successRedirect: '/profile' # redirect to the secure profile section
    failureRedirect: '/login' # redirect back to the signup page if there is an error
    failureFlash: true # allow flash messages
 
  app.get '/signup', (req, res) ->
    res.render 'signup.ejs', { message: req.flash('signupMessage') }

  # process the signup form
  app.post '/signup', passport.authenticate 'local-signup',
    successRedirect : '/profile' # redirect to the secure profile section
    failureRedirect : '/signup' # redirect back to the signup page if there is an error
    failureFlash : true # allow flash messages

  app.get '/connect/local', (req, res) ->
    res.render 'connect-local.ejs', { message: req.flash('loginMessage') }

  app.post '/connect/local', passport.authenticate 'local-signup', 
    successRedirect: '/profile' # redirect to the secure profile section
    failureRedirect: '/connect/local' # redirect back to the signup page if there is an error
    failureFlash: true # allow flash messages

  app.get '/unlink/local', isLoggedIn, (req, res) ->
    user                = req.user
    user.local.email    = undefined
    user.local.password = undefined
    user.save (err) ->
      res.redirect('/profile')

  # facebook #

  # send to facebook to do the authentication
  app.get '/auth/facebook', passport.authenticate('facebook', { scope : 'email' })

  # handle the callback after facebook has authenticated the user
  app.get '/auth/facebook/callback', passport.authenticate 'facebook', 
    successRedirect : '/profile'
    failureRedirect : '/'

  # send to facebook to do the authentication
  app.get '/connect/facebook', passport.authorize('facebook', { scope : 'email' })

  # handle the callback after facebook has authorized the user
  app.get '/connect/facebook/callback', passport.authorize 'facebook',
    successRedirect : '/profile'
    failureRedirect : '/'

  app.get '/unlink/facebook', isLoggedIn, (req, res) ->
    user                = req.user
    user.facebook.token = undefined
    user.save (err) ->
      res.redirect('/profile')

  # twitter #

  # send to twitter to do the authentication
  app.get '/auth/twitter', passport.authenticate('twitter', { scope : 'email' })

  # handle the callback after twitter has authenticated the user
  app.get '/auth/twitter/callback', passport.authenticate 'twitter',
    successRedirect : '/profile'
    failureRedirect : '/'

  # send to twitter to do the authentication
  app.get '/connect/twitter', passport.authorize('twitter', { scope : 'email' })

  # handle the callback after twitter has authorized the user
  app.get '/connect/twitter/callback', passport.authorize 'twitter', 
    successRedirect: '/profile'
    failureRedirect: '/'

  app.get '/unlink/twitter', isLoggedIn, (req, res) ->
    user               = req.user
    user.twitter.token = undefined
    user.save (err) ->
      res.redirect('/profile')

  # google #

  # send to google to do the authentication
  app.get '/auth/google', passport.authenticate('google', { scope : ['profile', 'email'] })

  # the callback after google has authenticated the user
  app.get '/auth/google/callback', passport.authenticate 'google',
    successRedirect : '/profile'
    failureRedirect : '/'

  # send to google to do the authentication
  app.get '/connect/google', passport.authorize('google', { scope : ['profile', 'email'] })

  # the callback after google has authorized the user
  app.get '/connect/google/callback', passport.authorize 'google', 
    successRedirect : '/profile'
    failureRedirect : '/'

  app.get '/unlink/google', isLoggedIn, (req, res) ->
    user              = req.user
    user.google.token = undefined
    user.save (err) ->
      res.redirect('/profile')


