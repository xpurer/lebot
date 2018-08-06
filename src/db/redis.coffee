Redis = require('ioredis')
CONFIG = require('./config.json')

module.exports = {
    redis: new Redis(CONFIG.REDIS)
    cache: new Redis(CONFIG.CACHE)
    R : require('./r.json')
}

