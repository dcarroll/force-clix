async   = require("async")
coffee  = require("coffee-script")
dd      = require("./lib/dd")
express = require("express")
log     = require("./lib/logger").init("force-cli")
redis   = require("redis-url").connect(process.env.REDIS_URL)
stdweb  = require("./lib/stdweb")
uuid    = require("node-uuid")

app = stdweb("force-cli")

app.get "/", (req, res) ->
  res.send "ok"

app.get "/auth/callback", (req, res) ->
  id = uuid.v4()
  redis.multi()
    .set(id, JSON.stringify(req.params))
    .expire(id, 300)
    .exec (err, foo) ->
      console.log "err", err
      console.log "foo", foo
      res.send id

app.start (port) ->
  console.log "listening on #{port}"
