# all environments
module.exports =
  mongo:
    url: "192.168.1.112"
    port: 27017
    database: "app"
  express:
    env: process.env.NODE_ENV || "development"
    port: process.env.PORT || 9090
    #host: process.env.HOST || "localhost"
    secret: "ilovescotchsctchscotchs"

  facebookAuth:
    clientID: "347363952139445" # your App ID
    clientSecret: "f0a8d15a289b5038115ff367e9c36af4" # your App Secret
    callbackURL: "https://auth.tegila.com.br/auth/facebook/callback"

  twitterAuth:
    consumerKey: "uYeftWa7njS8KMECabuqPqlIn"
    consumerSecret: "JjRurgEHTjn7GPtrclVNqWKqMAWOLZz8OpxeZzMp6b3Q8QpXcD"
    callbackURL: "https://auth.tegila.com.br/auth/twitter/callback"

  googleAuth:
    clientID: "69284261339-73nq4o79hr185ga2bb581mmofmf1bugu.apps.googleusercontent.com"
    clientSecret: "w2sjNRsa0jxdPlwLDU6CajvO"
    callbackURL: "https://auth.tegila.com.br/auth/google/callback"

  mercadolivreAuth:
    clientID: '5231044222134262'
    clientSecret: 'uV3JBzbNGqQwsSFxJstVegA0o9urLueC'
    callbackURL: 'https://auth.tegila.com.br/auth/mercadolivre/callback'
    authorizationURL: 'https://auth.mercadolivre.com.br/authorization'