database = {}

database.sqlite = nil

function database.load()
    local loadSQLite = require("libraries.sqlite3")

    local dllPath =
        love.filesystem.getSource() .. "/sqlite3.dll"

    database.sqlite = loadSQLite(dllPath)
end

function database.open(path)
    local code, db = database.sqlite.open(path)

    if code ~= database.sqlite.const.OK then
        return nil, "Could not open database. Code: " .. tostring(code)
    end

    return db
end

function database.exec(db, sql)
    local code = database.sqlite.exec(db, sql)

    if code ~= database.sqlite.const.OK then
        return false, database.sqlite.errmsg(db)
    end

    return true
end

function database.close(db)
    if db then
        database.sqlite.close(db)
    end
end