################################
# Misskey Core Server
################################

console.log 'Welcome to Misskey!'

# Imports
global <<< require \prelude-ls
global <<< require \./utils/json
global <<< require \./utils/null-or-empty
global <<< require \./models/utils/mongoose-query

# Create server
require './server'
