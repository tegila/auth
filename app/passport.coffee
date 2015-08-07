# load all the things we need
LocalStrategy    = require('passport-local').Strategy
FacebookStrategy = require('passport-facebook').Strategy
TwitterStrategy  = require('passport-twitter').Strategy
GoogleStrategy   = require('passport-google-oauth').OAuth2Strategy

# load up the user model
User = require('../app/models/user')

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

    # asynchronous
    process.nextTick ->
      User.findOne { 'local.email' :  email }, (err, user) ->
        # if there are any errors, return the error
        if (err)
          return done err

        # if no user is found, return the message
        if not user
          return done null, false, req.flash('loginMessage', 'No user found.')

        if not user.validPassword password
          return done null, false, req.flash('loginMessage', 'Oops! Wrong password.')

        # all is well, return user
        else
          return done null, user

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

    # asynchronous
    process.nextTick ->
      # if the user is not already logged in:
      if not req.user
        User.findOne { 'local.email' :  email }, (err, user) ->
          # if there are any errors, return the error
          if (err)
            return done(err)

          # check to see if theres already a user with that email
          if (user) 
            return done null, false, req.flash('signupMessage', 'That email is already taken.')
          else
            # create the user
            newUser = new User()

            newUser.local.email = email
            newUser.local.password = newUser.generateHash(password)

            newUser.save (err) ->
              if (err)
                return done(err)

              return done(null, newUser)

      # if the user is logged in but has no local account...
      else if not req.user.local.email
        # ...presumably they're trying to connect a local account
        # BUT let's check if the email used to connect a local account is being used by another user
        User.findOne { 'local.email' :  email }, (err, user) ->
          return done(err) if (err)
          
          if user
            return done null, false, req.flash('loginMessage', 'That email is already taken.')
            # Using 'loginMessage instead of signupMessage because it's used by /connect/local'
          else
            user = req.user
            user.local.email = email
            user.local.password = user.generateHash(password)
            user.save (err) ->
              return if (err) then done(err) else done(null,user)
      else
        # user is logged in and already has a local account. Ignore signup. (You should log out before trying to create a new account, user!)
        return done(null, req.user);

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
    

findOrCreate = (req, provider_name, profile, token, done) ->
  fillParams =  (user) ->
    if provider_name is 'facebook'
      name = profile.name.givenName + ' ' + profile.name.familyName
    else
      name = profile.displayName
    user[provider_name].id    = profile.id
    user[provider_name].token = token
    user[provider_name].name  = name
    #console.log profile
    user[provider_name].email = (profile.emails[0].value || '').toLowerCase()

    user.save (err) ->
      return if (err) then done(err) else done(null, user)

  # asynchronous
  process.nextTick ->
    # check if the user is already logged in
    if not req.user
      User.findOne {"#{provider_name}.id" : profile.id }, (err, user) ->
        return done(err) if (err)

        if user
          # if there is a user id already but no token (user was linked at one point and then removed)
          if user[provider_name].token
            return done(null, user) # user found, return that user
        else
          # if there is no user, create them
          user                = new User()

        fillParams user
    else
      # user already exists and is logged in, we have to link accounts
      user                = req.user # pull the user out of the session
      fillParams user