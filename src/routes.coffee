#
# Routes
#
version = require 'version-healthcheck'

app = module.parent.exports.app

main = require './controllers/main'

# Route: [/]
app.head '/', main.index
app.get '/', main.index

# Route: [/hash]
app.get '/hash', main.hash

# Route: [/yo]
app.get '/yo', main.yo

# Route: [/version]
app.get '/version', version
