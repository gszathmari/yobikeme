#
# Routes
#

app = module.parent.exports.app

main = require './controllers/main'

# Route: [/]
app.head '/', main.index
app.get '/', main.index

# Route: [/yo]
app.get '/yo', main.yo
