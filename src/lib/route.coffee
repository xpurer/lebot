Route = require('koa-router')
ROUTE = new Route()


module.exports = ROUTE
{isFunction} = require 'lodash'

bind = (method, prefix, func)->
    if isFunction(func)
        ROUTE[method](prefix, func)
    else
        for k,v of func
            bind(method, prefix+"/"+k, v)

map = (mod)->
    if typeof(mod) == 'string'
        m = require './url/'+mod
        for method,dict of m
            for k,v of dict
                bind method,'/'+mod+'/'+k, v
    else
        for k,v of mod
            for method, func of v
                bind method, k, func


get = (dict)->
    for k , v of dict
        bind('get', k, v)

module.exports = {
    map
    get
    bind
    route:ROUTE
}
# map 'room'
# _url_post = require('./url/post')
# get {
#     '/-:id(\\d+)\\.:table_id(\\d+)': require('./url/table_id.coffee')
#     '/-:id(\\d+)' : require('./url/gid')
#     '/-:id(\\d+)/feed\\.:end([-\\d]+)' : require('./url/feed')
#     '/-:id(\\d+)/post' : _url_post.get
#     '/-:id(\\d+)/month\\.:begin(\\d+)' : require('./url/month')
#     '/=:id(\\d+)' : require('./url/redirect')
# }

# _url_gid_name = require('./url/gid/name')
# bind 'get','/-:id(\\d+)/name' , _url_gid_name.get
# bind 'post','/name', _url_gid_name.post
# bind 'post','/post', _url_post.post

