path = require('path')

process.env.NODE_PATH = [
    path.resolve(__dirname)
    path.resolve(__dirname, "../node_modules")
    process.env.NODE_PATH
].join(":")
require('module').Module._initPaths()


{ promisify } = require('util')
{ readFile } = require('fs')
readFileAsync = promisify(readFile)
views = require('koa-views')
Koa = require('koa2')
app = new Koa()
bodyParser = require('koa-bodyparser')
app.use(bodyParser(
    enableTypes:'json form text'.split(' ')
))


{ORIGIN} = require('./config.json')
[ORIGIN_HTTP, ORIGIN_HOST] = ORIGIN.split("://")
ORIGIN_HOST = "."+ORIGIN_HOST
ORIGIN_HTTP = ORIGIN_HTTP+"://"

app.use (ctx, next) =>
    {origin} = ctx.headers
    if origin and (
        origin == ORIGIN or (
            origin.endsWith(ORIGIN_HOST) and \
            origin.startsWith(ORIGIN_HTTP)
        )
    )
        o = origin
    else
        o = ORIGIN
    ctx.set('Access-Control-Allow-Origin', o)
    ctx.set('Access-Control-Allow-Credentials', true)
    await next()

app.use(views(path.join(__dirname, './slm'), {
    extension: 'slm'
}))

pe = new (require('pretty-error'))()

app.on(
    'error'
    (err, ctx) =>
        console.error pe.render(err)
        console.trace err
)

run = (port)->
    route = require('./route')
    app.use(route.routes()).use(route.allowedMethods())
    app.listen(port)
    console.log "http://127.0.0.1:"+port

run(
    (process.argv.pop() - 0) or 3000
)
