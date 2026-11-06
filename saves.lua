
saves = {}

saves.slotCount = 3
saves.currentDB = nil
saves.currentSlot = nil

-- Проверява дали слотът е валиден
local function isValidSlot(slot)
    return type(slot) == "number"
        and slot % 1 == 0
        and slot >= 1
        and slot <= saves.slotCount
end

-- Път до сейва
local function getRelativePath(slot)
    return "saves/save_" .. slot .. ".db"
end

local function getFullPath(slot)
    return love.filesystem.getSaveDirectory()
        .. "/" .. getRelativePath(slot)
end

-- Отваря базата и активира Foreign Keys
local function openSaveDatabase(slot)
    local db, err = database.open(getFullPath(slot))

    if not db then
        return nil, err
    end

    local ok, sqlError = database.exec(
        db,
        "PRAGMA foreign_keys = ON;"
    )

    if not ok then
        database.close(db)
        return nil, sqlError
    end

    return db
end

-- Създава таблицата за доставките, ако липсва
-- Работи и със стари сейвове
local function ensureDeliveryTable(db)
    return database.exec(db, [[
        CREATE TABLE IF NOT EXISTS pending_deliveries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            game_state_id INTEGER NOT NULL DEFAULT 1,
            product_name TEXT NOT NULL,
            remaining_ms INTEGER NOT NULL,

            FOREIGN KEY (game_state_id)
                REFERENCES game_state(id)
                ON DELETE CASCADE
        );
    ]])
end

-- Проверява дали има сейв
function saves.exists(slot)
    if not isValidSlot(slot) then
        return false
    end

    return love.filesystem.getInfo(
        getRelativePath(slot)
    ) ~= nil
end

-- CREATE: Създава нов сейв
function saves.create(slot)

    if not isValidSlot(slot) then
        return false, "Invalid save slot."
    end

    if saves.exists(slot) then
        return false, "This save already exists."
    end

    love.filesystem.createDirectory("saves")

    local db, err = openSaveDatabase(slot)

    if not db then
        return false, err
    end

    -- Създава основните таблици
    local ok, sqlError = database.exec(db, [[
        CREATE TABLE game_state (
            id INTEGER PRIMARY KEY,
            money INTEGER NOT NULL,
            day INTEGER NOT NULL
        );

        CREATE TABLE inventory (
            item_name TEXT PRIMARY KEY,
            quantity INTEGER NOT NULL,
            game_state_id INTEGER NOT NULL DEFAULT 1,

            FOREIGN KEY (game_state_id)
                REFERENCES game_state(id)
                ON DELETE CASCADE
        );

        INSERT INTO game_state (id, money, day)
        VALUES (1, 100, 1);
    ]])

    -- Създава таблицата за поръчките
    if ok then
        ok, sqlError = ensureDeliveryTable(db)
    end

    database.close(db)

    if not ok then
        love.filesystem.remove(getRelativePath(slot))
        return false, sqlError
    end

    return true
end

-- LOAD: Отваря избран сейв
function saves.load(slot)

    if not isValidSlot(slot) then
        return nil, "Invalid save slot."
    end

    if not saves.exists(slot) then
        return nil, "Save does not exist."
    end

    saves.close()

    local db, err = openSaveDatabase(slot)

    if not db then
        return nil, err
    end

    -- Добавя таблицата и към старите сейвове
    local ok, sqlError = ensureDeliveryTable(db)

    if not ok then
        database.close(db)
        return nil, sqlError
    end

    saves.currentDB = db
    saves.currentSlot = slot

    return saves.read()
end

-- READ: Прочита запазените данни
function saves.read()

    if not saves.currentDB then
        return nil, "No save is currently loaded."
    end

    local sqlite = database.sqlite
    local db = saves.currentDB

    -- Прочита парите и деня
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
        inventory = {},
        pendingDeliveries = {}
    }

    sqlite.finalize(stmt)

    -- Прочита инвентара
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

            local itemName =
                sqlite.column_text(inventoryStmt, 0)

            local quantity =
                sqlite.column_int(inventoryStmt, 1)

            data.inventory[itemName] = quantity

        elseif inventoryResult == sqlite.const.DONE then
            break

        else
            local err = sqlite.errmsg(db)
            sqlite.finalize(inventoryStmt)
            return nil, err
        end
    end

    sqlite.finalize(inventoryStmt)

    -- Прочита чакащите доставки
    local orderCode, orderStmt = sqlite.prepare_v2(db, [[
        SELECT product_name, remaining_ms
        FROM pending_deliveries
        WHERE game_state_id = 1
        ORDER BY id;
    ]])

    if orderCode ~= sqlite.const.OK then
        return nil, sqlite.errmsg(db)
    end

    while true do
        local orderResult = sqlite.step(orderStmt)

        if orderResult == sqlite.const.ROW then

            local productName =
                sqlite.column_text(orderStmt, 0)

            local remainingMs =
                sqlite.column_int(orderStmt, 1)

            -- Превръща милисекундите в секунди
            table.insert(data.pendingDeliveries, {
                productName = productName,
                timer = remainingMs / 1000
            })

        elseif orderResult == sqlite.const.DONE then
            break

        else
            local err = sqlite.errmsg(db)
            sqlite.finalize(orderStmt)
            return nil, err
        end
    end

    sqlite.finalize(orderStmt)

    return data
end

-- UPDATE: Записва текущия прогрес
function saves.update(data)

    if not saves.currentDB then
        return false, "No save is currently loaded."
    end

    if type(data) ~= "table"
        or type(data.money) ~= "number"
        or type(data.day) ~= "number" then
        return false, "Invalid save data."
    end

    if data.inventory ~= nil
        and type(data.inventory) ~= "table" then
        return false, "Inventory must be a table."
    end

    if data.pendingDeliveries ~= nil
        and type(data.pendingDeliveries) ~= "table" then
        return false, "Invalid deliveries."
    end

    -- Проверява данните преди записване
    if data.inventory ~= nil then
        for itemName, quantity in pairs(data.inventory) do
            if type(itemName) ~= "string"
                or type(quantity) ~= "number"
                or quantity < 0 then
                return false, "Invalid inventory entry."
            end
        end
    end

    if data.pendingDeliveries ~= nil then
        for _, order in ipairs(data.pendingDeliveries) do
            if type(order) ~= "table"
                or type(order.productName) ~= "string"
                or type(order.timer) ~= "number"
                or order.timer ~= order.timer then
                return false, "Invalid delivery entry."
            end
        end
    end

    local sqlite = database.sqlite
    local db = saves.currentDB

    -- Записва всички промени като една операция
    local ok, err = database.exec(
        db,
        "BEGIN TRANSACTION;"
    )

    if not ok then
        return false, err
    end

    -- При грешка отменя незавършения запис
    local function rollback(message)
        database.exec(db, "ROLLBACK;")
        return false, message
    end

    -- Обновява парите и деня
    local code, stmt = sqlite.prepare_v2(db, [[
        UPDATE game_state
        SET money = ?, day = ?
        WHERE id = 1;
    ]])

    if code ~= sqlite.const.OK then
        return rollback(sqlite.errmsg(db))
    end

    sqlite.bind_int(stmt, 1, math.floor(data.money))
    sqlite.bind_int(stmt, 2, math.floor(data.day))

    local result = sqlite.step(stmt)
    sqlite.finalize(stmt)

    if result ~= sqlite.const.DONE then
        return rollback(sqlite.errmsg(db))
    end

    -- Обновява инвентара
    if data.inventory ~= nil then

        local inventoryOK, inventoryError =
            database.exec(db, "DELETE FROM inventory;")

        if not inventoryOK then
            return rollback(inventoryError)
        end

        for itemName, quantity in pairs(data.inventory) do

            local insertCode, insertStmt =
                sqlite.prepare_v2(db, [[
                    INSERT INTO inventory
                        (item_name, quantity)
                    VALUES (?, ?);
                ]])

            if insertCode ~= sqlite.const.OK then
                return rollback(sqlite.errmsg(db))
            end

            sqlite.bind_text(insertStmt, 1, itemName)
            sqlite.bind_int(
                insertStmt,
                2,
                math.floor(quantity)
            )

            local insertResult = sqlite.step(insertStmt)
            sqlite.finalize(insertStmt)

            if insertResult ~= sqlite.const.DONE then
                return rollback(sqlite.errmsg(db))
            end
        end
    end

    -- Записва чакащите доставки
    if data.pendingDeliveries ~= nil then

        -- Премахва стария списък
        local deleteOK, deleteError = database.exec(
            db,
            "DELETE FROM pending_deliveries;"
        )

        if not deleteOK then
            return rollback(deleteError)
        end

        -- Записва всяка поръчка поотделно
        for _, order in ipairs(data.pendingDeliveries) do

            local insertCode, insertStmt =
                sqlite.prepare_v2(db, [[
                    INSERT INTO pending_deliveries
                        (product_name, remaining_ms)
                    VALUES (?, ?);
                ]])

            if insertCode ~= sqlite.const.OK then
                return rollback(sqlite.errmsg(db))
            end

            -- Превръща секундите в милисекунди
            local remainingMs = math.floor(
                math.max(0, order.timer) * 1000 + 0.5
            )

            sqlite.bind_text(
                insertStmt,
                1,
                order.productName
            )

            sqlite.bind_int(
                insertStmt,
                2,
                remainingMs
            )

            local insertResult = sqlite.step(insertStmt)
            sqlite.finalize(insertStmt)

            if insertResult ~= sqlite.const.DONE then
                return rollback(sqlite.errmsg(db))
            end
        end
    end

    -- Потвърждава всички промени
    local commitOK, commitError =
        database.exec(db, "COMMIT;")

    if not commitOK then
        return rollback(commitError)
    end

    return true
end

-- DELETE: Изтрива сейв
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

    return love.filesystem.remove(
        getRelativePath(slot)
    )
end

-- Затваря базата
function saves.close()

    if saves.currentDB then
        database.close(saves.currentDB)
        saves.currentDB = nil
        saves.currentSlot = nil
    end
end

-- Връща списъка със сейвове
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
