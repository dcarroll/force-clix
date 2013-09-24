async   = require("async")
coffee  = require("coffee-script")
dd      = require("./lib/dd")
express = require("express")
log     = require("./lib/logger").init("force-cli")
redis   = require("redis-url").connect(process.env.REDIS_URL)
stdweb  = require("./lib/stdweb")
url     = require("url")
uuid    = require("node-uuid")

app = stdweb("force-cli")

app.use express.static("#{__dirname}/public")

app.get "/", (req, res) ->
  res.send "ok"

app.get "/auth/callback", (req, res) ->
  res.render "auth.jade"

app.start (port) ->
  console.log "listening on #{port}"
