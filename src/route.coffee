{map,get,bind} = require('./lib/route')


url_mac = require('./url/mac')

get {
    '/mac/:mac(\\w+)':url_mac.get
    '/mac/:mac(\\w+)/:ip(\\w+)':url_mac.set
}
