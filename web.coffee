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

app.post "/key", (req, res) ->
  id = uuid.v4()
  console.log "req.body", req.body
  redis.multi()
    .set(id, JSON.stringify(req.body))
    .expire(id, 300)
    .exec (err) ->
      res.send id

app.get "/key/:id", (req, res) ->
  redis.get req.params.id, (err, data) ->
    return res.send("no such key", 404) if err
    res.contentType "application/json"
    res.send data

app.start (port) ->
  console.log "listening on #{port}"
