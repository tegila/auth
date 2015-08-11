# server.js

# set up ======================================================================
# get all the tools we need
express  = require('express')
app      = do express
mongoose = require('mongoose')

passport = require('passport')
flash    = require('connect-flash')

morgan         = require('morgan')
cookieParser   = require('cookie-parser')
bodyParser     = require('body-parser')
multer         = require("multer")
errorHandler   = require("errorhandler")
methodOverride = require("method-override")
session        = require('express-session')
MongoStore     = require('connect-mongo')(session)

config = require './app/config'

# configuration ===============================================================
# connect to our database
mongoose.connect("mongodb://#{config.mongo.url}:#{config.mongo.port}/#{config.mongo.database}") 

# express http verb setup
app.use do cookieParser # read cookies (needed for auth)
app.use do methodOverride
## express addons
app.use do bodyParser.json
app.use bodyParser.urlencoded(extended: true)
app.use do multer

## Debugger
app.use morgan("dev")
app.use errorHandler
  dumpExceptions: true
  showStack: true

app.set 'view engine', 'ejs' # set up ejs for templating

# required for passport mongo session
app.use session 
  saveUninitialized: false # don't create session until something stored
  resave: false #don't save session if unmodified
  store: new MongoStore
    url: 'mongodb://192.168.1.112:27017/temp'
  secret: config.express.secret # session secret
  cookie: 
    domain: ".tegila.com.br"
    maxAge: 3600000

app.use do passport.initialize
app.use do passport.session # persistent login sessions
app.use do flash # use connect-flash for flash messages stored in session

require('./app/passport')(passport) # pass passport for configuration
# routes ======================================================================
# load our routes and pass in our app and fully configured passport
require('./app/routes')(app, passport) 

# launch ======================================================================
app.listen config.express.port
console.log "The magic happens on port #{config.express.port}"
