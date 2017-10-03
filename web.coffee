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
oldHomePage = "res.render 'index.jade'"

app.use express.static("#{__dirname}/public")

app.get "/", (req, res) ->
  res.redirect("https://developer.salesforce.com/tools/forcecli")

app.get "/auth/soaplogin", (req, res) ->
  try
    force = new sf.Connection instanceUrl:req.query.instance_url, accessToken:req.query.access_token
    console.log "querydata", JSON.stringify(req.query, 4, null)
    user_id = req.query.id.split("/").pop()
    org_id  = req.query.access_token.split("!").shift()
    console.log "user_id", user_id
    console.log "org_id", org_id
    force.sobject("User").find(Id:user_id, "Email").execute (err, users) ->
      force.sobject("Organization").find(Id:org_id, "Name").execute (err, orgs) ->
        postgres (err, db) ->
          db.query "INSERT INTO logins (email, org, date, login_method) VALUES ($1, $2, NOW(), $3)", [ users[0].Email, orgs[0].Name, 'SOAP' ], (err, rows) ->
            console.log "error saving login", err if err
            console.log "Inserted ", rows
            db.end()
  catch err
    console.log "error saving soap login", err
    res.send err
  res.send "ok"

app.get "/auth/credentials", (req, res) ->
  try
    force = new sf.Connection instanceUrl:req.query.instance_url, accessToken:req.query.access_token
    console.log "querydata", JSON.stringify(req.query, 4, null)
    user_id = req.query.id.split("/").pop()
    org_id  = req.query.access_token.split("!").shift()
    console.log "user_id", user_id
    console.log "org_id", org_id
    force.sobject("User").find(Id:user_id, "Email").execute (err, users) ->
      force.sobject("Organization").find(Id:org_id, "Name").execute (err, orgs) ->
        postgres (err, db) ->
          db.query "INSERT INTO logins (email, org, date, login_method) VALUES ($1, $2, NOW(), $3)", [ users[0].Email, orgs[0].Name, 'OAUTH' ], (err, rows) ->
            console.log "error saving login", err if err
            db.end()
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
