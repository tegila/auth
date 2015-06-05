# server.js

# set up ======================================================================
# get all the tools we need
express  = require('express')
app      = express()
port     = process.env.PORT || 8080
mongoose = require('mongoose')
passport = require('passport')
flash    = require('connect-flash')

morgan       = require('morgan')
cookieParser = require('cookie-parser')
bodyParser   = require('body-parser')
session      = require('express-session')
MongoStore   = require('connect-mongo')(session)

configDB   = require('./config/database')

# configuration ===============================================================
mongoose.connect(configDB.url) # connect to our database

require('./config/passport')(passport) # pass passport for configuration

# set up our express application
app.use morgan('dev') # log every request to the console
app.use do cookieParser # read cookies (needed for auth)
app.use bodyParser.json() # get information from html forms
app.use bodyParser.urlencoded { extended: true }

app.set 'view engine', 'ejs' # set up ejs for templating

# required for passport
app.use session 
  saveUninitialized: false # don't create session until something stored
  resave: false #don't save session if unmodified
  store: new MongoStore
    url: 'mongodb://192.168.1.112:27017/passport'
    touchAfter: 24 * 3600 # time period in seconds
  secret: 'ilovescotchsctchscotch' # session secret
  cookie: 
    #domain : "tegila.com.br"
    httpOnly : true
    path     : '/'

app.use do passport.initialize
app.use do passport.session # persistent login sessions
app.use do flash # use connect-flash for flash messages stored in session

# routes ======================================================================
require('./app/routes')(app, passport) # load our routes and pass in our app and fully configured passport

# launch ======================================================================
app.listen port
console.log "The magic happens on port #{port}"
