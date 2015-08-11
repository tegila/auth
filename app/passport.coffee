# load all the things we need
LocalStrategy    = require('passport-local').Strategy
FacebookStrategy = require('passport-facebook').Strategy
TwitterStrategy  = require('passport-twitter').Strategy
GoogleStrategy   = require('passport-google-oauth').OAuth2Strategy
MercadoLibreStrategy = require('passport-mercadolibre').Strategy

# load up the user model
User = require('../app/models/user')

crypto = require('crypto')

config = require './config'

# load the auth variables
module.exports = (passport, db) ->

  # =========================================================================
  # passport session setup ==================================================
  # =========================================================================
  # required for persistent login sessions
  # passport needs ability to serialize and unserialize users out of session

  # used to serialize the user for the session
  passport.serializeUser (user, done) ->
    console.log "passport.coffee:23 user.id = #{user.id}"
    done(null, user.id)

  # used to deserialize the user
  passport.deserializeUser (id, done) ->
    console.log "passport.coffee:28 id = #{id}"
    User.findById id, (err, user) ->
      done(err, user)

  # =========================================================================
  # LOCAL LOGIN =============================================================
  # =========================================================================
  passport.use 'local-login', new LocalStrategy
    # by default, local strategy uses username and password, we will override with email
    usernameField : 'email'
    passwordField : 'password'
    passReqToCallback : true # allows us to pass in the req from our route (lets us check if a user is logged in or not)
  ,(req, email, password, done) ->
    if (email)
      email = do email.toLowerCase # Use lower-case e-mails to avoid case-sensitive e-mail matching
      password = crypto.createHash('md5').update(password).digest('hex')

    # asynchronous
    process.nextTick ->
      User.findOne {'local.email':email, 'local.password':password}, (err, user) ->
        # if no user is found, return the message
        if not user
          done null, false, req.flash('loginMessage', 'No user found.')
        # all is well, return user
        else
          done null, user

  # =========================================================================
  # LOCAL SIGNUP ============================================================
  # =========================================================================
  passport.use 'local-signup', new LocalStrategy
    # by default, local strategy uses username and password, we will override with email
    usernameField: 'email'
    passwordField: 'password'
    passReqToCallback: true # allows us to pass in the req from our route (lets us check if a user is logged in or not)
  ,(req, email, password, done) ->
    if (email)
      email = do email.toLowerCase # Use lower-case e-mails to avoid case-sensitive e-mail matching
      password = crypto.createHash('md5').update(password).digest('hex')

    # asynchronous
    process.nextTick ->
      # if the user is not already logged in:
      
      User.findOne {'local.email':email, 'local.password':password}, (err, user) ->
        # if there are any errors, return the error
        if (err)
          return done(err)
        
        if user # exists
          return done(null, user)
        else if req.user # logged in
          user = req.user
        else # new user
          user = new User()

        user.local.email = email
        user.local.password = password
        user.save (err) ->
          return if (err) then done(err) else done(null,user)


  # =========================================================================
  # FACEBOOK ================================================================
  # =========================================================================
  passport.use new FacebookStrategy
    clientID: config.facebookAuth.clientID
    clientSecret: config.facebookAuth.clientSecret
    callbackURL: config.facebookAuth.callbackURL
    passReqToCallback: true # allows us to pass in the req from our route (lets us check if a user is logged in or not)
  ,(req, token, refreshToken, profile, done) ->
    findOrCreate req, 'facebook', profile, token, done
      

  # =========================================================================
  # TWITTER =================================================================
  # =========================================================================
  passport.use new TwitterStrategy
    consumerKey     : config.twitterAuth.consumerKey
    consumerSecret  : config.twitterAuth.consumerSecret
    callbackURL     : config.twitterAuth.callbackURL
    passReqToCallback : true # allows us to pass in the req from our route (lets us check if a user is logged in or not)
  , (req, token, tokenSecret, profile, done) ->
    findOrCreate(req, 'twitter', profile, token, done)

  # =========================================================================
  # GOOGLE ==================================================================
  # =========================================================================
  passport.use new GoogleStrategy
    clientID        : config.googleAuth.clientID
    clientSecret    : config.googleAuth.clientSecret
    callbackURL     : config.googleAuth.callbackURL
    passReqToCallback : true # allows us to pass in the req from our route (lets us check if a user is logged in or not)
  ,(req, token, refreshToken, profile, done) ->
    findOrCreate(req, 'google', profile, token, done)
    

  # =========================================================================
  # MERCADOLIVRE ==================================================================
  # =========================================================================

  passport.use new MercadoLibreStrategy
    clientID: config.mercadolivreAuth.clientID
    clientSecret: config.mercadolivreAuth.clientSecret
    callbackURL: config.mercadolivreAuth.callbackURL
    authorizationURL: config.mercadolivreAuth.authorizationURL
    passReqToCallback : true
  , (req, token, refreshToken, profile, done) ->
    findOrCreate(req, 'mercadolivre', profile, token, done)


findOrCreate = (req, provider_name, profile, token, done) ->
  fillparams = (user) ->
    user ?= new User()
    user[provider_name].id    = profile.id
    user[provider_name].token = token
    user[provider_name].refreshToken = req.query.code
    user[provider_name].profile  = profile

    user.save (err) ->
      return if (err) then done(err) else done(null, user)

  # asynchronous
  process.nextTick ->
    
    # check if the user is already logged in
    if req.user
      # user already exists and is logged in, we have to link accounts
      user = req.user # pull the user out of the session
      fillparams user
    else
      User.findOne {"#{provider_name}.id" : profile.id }, (err, user) ->
        if user
          return done(null, user) # user found, return that user
        fillparams user

    

