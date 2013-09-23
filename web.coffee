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

app.get "/", (req, res) ->
  res.send "ok"

app.get "/auth/callback", (req, res) ->
  id = uuid.v4()
  parts = req.url.split("#")
  parts.shift()
  query = url.parse(parts.join("#"))
  console.log "query", query
  console.log "req.url", req.url
  console.log "req.query", req.query
  redis.multi()
    .set(id, JSON.stringify(req.query))
    .expire(id, 300)
    .exec (err, foo) ->
      res.send id

app.get "/key/:id", (req, res) ->
  redis.get req.params.id, (err, data) ->
    return res.send("no such key", 404) if err
    res.send data

app.start (port) ->
  console.log "listening on #{port}"
