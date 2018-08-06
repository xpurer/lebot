CONFIG = require('./config.json')
Knex = require('knex')
_pg = require('pg')
require('pg-parse-float')(_pg)
_pg.types.setTypeParser(20, parseInt)

module.exports = PG = Knex({
    # debug:config.debug
    client: 'pg',
    connection: CONFIG.PSQL
    searchPath: 'public'
    pool: { min: 0, max: 7 }
    acquireConnectionTimeout: 10000
}).on(
    'query-error'
    (error, obj)->
        console.error error
)

Object.assign(
    PG
    {
    rows : ->
        args = []
        for i in arguments
            args.push i
        sql = args.shift()
        r = await (@raw.call(
            @
            sql
            args
        ))
        return r.rows or []

    one: ->
        (await (@rows.apply(@,arguments)))[0]

    get:(table, id, column="*")->
        await @one("SELECT #{column} FROM #{table} WHERE id=?", id)

    get_li:(table, id_li, column="*") ->
        if not id_li.length
            return []
        li = []
        for i in id_li
            li.push(i-0)
        await @rows("SELECT #{column} FROM #{table} WHERE id IN (#{li.join(',')})")


    select_id: (table, column, value)->
        sql = "SELECT id FROM #{table} WHERE #{column}=? LIMIT 1"
        r = await @raw(
            sql
            value
        )
        if r.rowCount
            return r.rows[0].id
        return 0

    insert_id: (table, column, value)->

        if value instanceof Array
            val = []
            i = value.length
            while i--
                val.push '?'
            val = val.join(',')
        else
            val = '?'

        sql = "INSERT INTO #{table} (#{column}) VALUES (#{val}) RETURNING id"
        r = await @raw(
            sql
            value
        )
        return r.rows[0].id

    upsert_id: (table, column, value)->
        # ON CONFLICT的sql会更新seq id，不要用
        sql = """with s as ( select id from #{table} where #{column}=?),
i as (
insert into #{table} (#{column})
select ? where not exists (select 1 from s)
returning id
)
select id from i union all select id from s"""
        r = await @raw(
            sql
            [value,value]
        )
        return r.rows[0].id
    }
)
