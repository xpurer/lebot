{R, redis, cache} = require 'db/redis'
require 'core/sprintf'

module.exports = {
    R
    redis
    cache
    PG : require 'db/pg'
    MC : require 'db/mc'
}


