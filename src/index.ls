global <<< require \prelude-ls
global <<< require \./utils/json
global <<< require \./utils/null-or-empty
global <<< require \./models/utils/mongoose-query

require './web/server'
require './api/server'
