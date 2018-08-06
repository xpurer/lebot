PG = require('./pg')
{cache} = require("./redis")


dump_func = (column)->
    (o)->
        o[column]


module.exports = exports = {
    memory : (timeout)->
        timeout = timeout * 1000
        (func) ->
            MEMORY = new (require('memory-cache').Cache)()
            return (key)->
                r = MEMORY.get(key)
                if null == r
                    r = await func.apply @,arguments
                    MEMORY.put(
                        key
                        r
                        timeout
                    )
                return r

    by_id: (key,  table, column, dump, load)->
        if not dump
            dump = dump_func(column)

        li = (id_li)->
            if not id_li.length
                return []

            r = await cache.hmget([key].concat(id_li))

            _pos = {}
            _id_li = []

            for i,pos in id_li
                o = r[pos]
                if o == null
                    _id_li.push i
                    _pos[i] = pos

            if _id_li.length
                li = await PG.get_li(table, _id_li, "id,#{column}")

                to_set = []
                for i in li
                    s = dump(i)
                    id = i.id
                    r[_pos[id]] =s
                    to_set.push(id)
                    to_set.push(s)

                if to_set.length
                    cache.hmset [key].concat(to_set)
            if load
                r = r.map load
            return r

        get = (id)->
            r = await cache.hget(key, id)
            if r == null
                o = await PG.get(table, id, column)
                if o
                    r = dump(o)
                    cache.hset key, id, r
            if load
                r = load(r)
            return r

        get.li = li

        return get

    hset : (key, get, filter)->
        (li)->
            if not li.length
                return []

            if filter
                li = filter(li)

            d = await cache.hmget(key,li)

            r = []
            to_set = []

            for i, pos in li
                id = d[pos]
                if id == null
                    id = await get(i)
                    if id
                        to_set.push i
                        to_set.push id
                    else
                        continue
                r.push id

            if to_set.length
                await cache.hmset [key].concat(to_set)

            return r
}
