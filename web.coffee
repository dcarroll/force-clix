async   = require("async")
coffee  = require("coffee-script")
dd      = require("./lib/dd")
express = require("express")
log     = require("./lib/logger").init("force-cli")
stdweb  = require("./lib/stdweb")
uuid    = require("node-uuid")

app = stdweb("force-cli")

app.get "/", (req, res) ->
  res.send "ok"

app.get "/auth/callback", (req, res) ->
  console.log "req.body", req.body
  console.log "req.params", req.params
  res.send "ok"

app.start (port) ->
  console.log "listening on #{port}"
