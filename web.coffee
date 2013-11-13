async   = require("async")
coffee  = require("coffee-script")
dd      = require("./lib/dd")
express = require("express")
log     = require("./lib/logger").init("force-cli")
pg      = require("pg")
sf      = require("node-salesforce")
stdweb  = require("./lib/stdweb")
url     = require("url")
uuid    = require("node-uuid")

postgres = (cb) ->
  client = new pg.Client(process.env.POSTGRESQL_URL)
  client.connect (err) -> cb err, client

app = stdweb("force-cli")

app.use express.static("#{__dirname}/public")

app.get "/", (req, res) ->
  res.send "ok"

app.get "/auth/credentials", (req, res) ->
  try
    force = new sf.Connection instanceUrl:req.query.instance_url, accessToken:req.query.access_token
    user_id = req.query.id.split("/").pop()
    org_id  = req.query.access_token.split("!").shift()
    console.log "user_id", user_id
    console.log "org_id", org_id
    force.sobject("User").find(Id:user_id, "Email").execute (err, users) ->
      force.sobject("Organization").find(Id:org_id, "Name").execute (err, orgs) ->
        postgres (err, db) ->
          db.query "INSERT INTO logins (email, org, date) VALUES ($1, $2, NOW())", [ users[0].Email, orgs[0].Name ], (err, rows) ->
            console.log "error saving login", err if err
  catch err
    console.log "error saving login", err
  res.send "ok"

app.get "/auth/callback", (req, res) ->
  res.render "callback.jade"

app.get "/auth/complete", (req, res) ->
  res.header "Access-Control-Allow-Origin", "*"
  res.render "complete.jade"

app.start (port) ->
  console.log "listening on #{port}"
