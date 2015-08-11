# load the things we need
mongoose = require('mongoose')

# define the schema for our user model
userSchema = mongoose.Schema
  local:
    email: String
    password: String
  facebook:
    id: String
    token: String
    profile: Object
    email: String
    name: String
  twitter:
    id: String
    token: String
    profile: Object
    displayName: String
    username: String
  google:
    id: String
    token: String
    email: String
    profile: Object
    name: String
  mercadolivre:
    id: String
    token: String
    refreshToken: String
    profile: Object

# create the model for users and expose it to our app
module.exports = mongoose.model('User', userSchema)
