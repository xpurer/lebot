#{PG} = require 'db/all'

module.exports = {
    get:(ctx)->
        {mac} = ctx.params
        ctx.body = mac

    set:(ctx)->
        {mac,ip} = ctx.params
        ctx.body = "mac "+ip
}
