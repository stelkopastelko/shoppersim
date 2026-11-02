saves = {}

saves.slotCount = 3
saves.currentDB = nil
saves.currentSlot = nil

local function isValidSlot(slot)
    return type(slot) == "number"
        and slot % 1 == 0
        and slot >= 1
        and slot <= saves.slotCount
end

local function getRelativePath(slot)
    return "saves/save_" .. slot .. ".db"
end

local function getFullPath(slot)
    return love.filesystem.getSaveDirectory()
        .. "/" .. getRelativePath(slot)
end

function saves.exists(slot)
    if not isValidSlot(slot) then
        return false
    end

    return love.filesystem.getInfo(getRelativePath(slot)) ~= nil
end

-- CREATE
function saves.create(slot)
    if not isValidSlot(slot) then
        return false, "Invalid save slot."
    end

    if saves.exists(slot) then
        return false, "This save already exists."
    end

    love.filesystem.createDirectory("saves")

    local db, err = database.open(getFullPath(slot))

    if not db then
        return false, err
    end

    local ok, sqlError = database.exec(db, [[
        CREATE TABLE game_state (
            id INTEGER PRIMARY KEY,
            money INTEGER NOT NULL,
            day INTEGER NOT NULL
        );

        CREATE TABLE inventory (
            item_name TEXT PRIMARY KEY,
            quantity INTEGER NOT NULL
        );

        INSERT INTO game_state (id, money, day)
        VALUES (1, 100, 1);
    ]])

    database.close(db)

    if not ok then
        love.filesystem.remove(getRelativePath(slot))
        return false, sqlError
    end

    return true
end

-- READ
function saves.load(slot)
    if not isValidSlot(slot) then
        return nil, "Invalid save slot."
    end

    if not saves.exists(slot) then
        return nil, "Save does not exist."
    end

    saves.close()

    local db, err = database.open(getFullPath(slot))

    if not db then
        return nil, err
    end

    saves.currentDB = db
    saves.currentSlot = slot

    return saves.read()
end

function saves.read()
    if not saves.currentDB then
        return nil, "No save is currently loaded."
    end

    local sqlite = database.sqlite
    local db = saves.currentDB

    local code, stmt = sqlite.prepare_v2(db, [[
        SELECT money, day
        FROM game_state
        WHERE id = 1;
    ]])

    if code ~= sqlite.const.OK then
        return nil, sqlite.errmsg(db)
    end

    local result = sqlite.step(stmt)

    if result ~= sqlite.const.ROW then
        sqlite.finalize(stmt)
        return nil, "Could not read save data."
    end

    local data = {
        money = sqlite.column_int(stmt, 0),
        day = sqlite.column_int(stmt, 1),
        inventory = {}
    }

    sqlite.finalize(stmt)

    local code2, inventoryStmt = sqlite.prepare_v2(db, [[
        SELECT item_name, quantity
        FROM inventory;
    ]])

    if code2 ~= sqlite.const.OK then
        return nil, sqlite.errmsg(db)
    end

    while true do
        local inventoryResult = sqlite.step(inventoryStmt)

        if inventoryResult == sqlite.const.ROW then
            local itemName = sqlite.column_text(inventoryStmt, 0)
            local quantity = sqlite.column_int(inventoryStmt, 1)

            data.inventory[itemName] = quantity

        elseif inventoryResult == sqlite.const.DONE then
            break

        else
            sqlite.finalize(inventoryStmt)
            return nil, sqlite.errmsg(db)
        end
    end

    sqlite.finalize(inventoryStmt)

    return data
end

-- UPDATE
function saves.update(data)
    if not saves.currentDB then
        return false, "No save is currently loaded."
    end

    if type(data.money) ~= "number"
        or type(data.day) ~= "number" then
        return false, "Invalid save data."
    end

    if data.inventory ~= nil and type(data.inventory) ~= "table" then
        return false, "Inventory must be a table."
    end

    local sqlite = database.sqlite
    local db = saves.currentDB

    local code, stmt = sqlite.prepare_v2(db, [[
        UPDATE game_state
        SET money = ?, day = ?
        WHERE id = 1;
    ]])

    if code ~= sqlite.const.OK then
        return false, sqlite.errmsg(db)
    end

    sqlite.bind_int(stmt, 1, math.floor(data.money))
    sqlite.bind_int(stmt, 2, math.floor(data.day))

    local result = sqlite.step(stmt)
    sqlite.finalize(stmt)

    if result ~= sqlite.const.DONE then
        return false, sqlite.errmsg(db)
    end

    if data.inventory ~= nil then
        local ok, err = database.exec(db, "DELETE FROM inventory;")

        if not ok then
            return false, err
        end

        for itemName, quantity in pairs(data.inventory) do
            if type(itemName) ~= "string"
                or type(quantity) ~= "number"
                or quantity < 0 then
                return false, "Invalid inventory entry."
            end

            local insertCode, insertStmt = sqlite.prepare_v2(db, [[
                INSERT INTO inventory (item_name, quantity)
                VALUES (?, ?);
            ]])

            if insertCode ~= sqlite.const.OK then
                return false, sqlite.errmsg(db)
            end

            sqlite.bind_text(insertStmt, 1, itemName)
            sqlite.bind_int(insertStmt, 2, math.floor(quantity))

            local insertResult = sqlite.step(insertStmt)
            sqlite.finalize(insertStmt)

            if insertResult ~= sqlite.const.DONE then
                return false, sqlite.errmsg(db)
            end
        end
    end

    return true
end

-- DELETE
function saves.delete(slot)
    if not isValidSlot(slot) then
        return false, "Invalid save slot."
    end

    if not saves.exists(slot) then
        return false, "Save does not exist."
    end

    if saves.currentSlot == slot then
        saves.close()
    end

    return love.filesystem.remove(getRelativePath(slot))
end

function saves.close()
    if saves.currentDB then
        database.close(saves.currentDB)
        saves.currentDB = nil
        saves.currentSlot = nil
    end
end

function saves.list()
    local result = {}

    for slot = 1, saves.slotCount do
        table.insert(result, {
            slot = slot,
            exists = saves.exists(slot)
        })
    end

    return result
end