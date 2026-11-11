
local shelves = {}

-- Позиции на рафтовете в магазина
-- Координатите са приблизително според картата

local shelfRows = {
    {
        y = 240,
        xs = {96, 624, 864, 1056, 1296, 1536, 1776}
    },
    {
        y = 480,
        xs = {144, 384, 624, 864, 1056, 1296, 1536, 1776}
    },
    {
        y = 720,
        xs = {144, 384, 624, 864, 1056, 1296, 1536, 1776}
    }
}

shelves.list = {}
shelves.itemQuads = {}

-- Разстояние за взаимодействие
shelves.interactionDistance = 110


-- ЗАРЕЖДАНЕ НА РАФТОВЕТЕ
function shelves.load()

    shelves.list = {}

    local id = 0

    for _, row in ipairs(shelfRows) do

        for _, x in ipairs(row.xs) do

            id = id + 1

            table.insert(shelves.list, {
                id = id,
                x = x,
                y = row.y,
                productName = nil,
                quantity = 0
            })
        end
    end


    -- Създава изображения за отделните продукти
    local sheetWidth =
        delivery.productSheet:getWidth()

    local sheetHeight =
        delivery.productSheet:getHeight()

    shelves.itemQuads = {}

    -- Продуктите са на първия ред
    for i, productName in ipairs(delivery.products) do

        shelves.itemQuads[productName] =
            love.graphics.newQuad(
                (i - 1) * delivery.frameWidth,
                0,
                delivery.frameWidth,
                delivery.frameHeight,
                sheetWidth,
                sheetHeight
            )
    end
end


-- НАМИРА НАЙ-БЛИЗКИЯ ПОДХОДЯЩ РАФТ
function shelves.getNearbyShelf(productName)

    if map.current ~= "assets/maps/shopmap.lua" then
        return nil
    end

    if not shop.products[productName] then
        return nil
    end

    local playerX, playerY =
        player.collider:getPosition()

    local nearestShelf = nil
    local nearestDistance =
        shelves.interactionDistance

    local boxQuantity =
        shop.products[productName].itemsPerBox

    -- Засега всеки рафт побира 3 кашона
    local maxStock = boxQuantity * 3

    for _, shelf in ipairs(shelves.list) do

        -- Празен рафт или рафт със същия продукт
        if shelf.productName == nil
            or shelf.productName == productName then

            -- Проверява дали има място
            if shelf.quantity + boxQuantity <= maxStock then

                local distance = math.sqrt(
                    (playerX - shelf.x)^2 +
                    (playerY - shelf.y)^2
                )

                if distance <= nearestDistance then

                    nearestDistance = distance
                    nearestShelf = shelf
                end
            end
        end
    end

    return nearestShelf
end


-- ЗАРЕЖДАНЕ НА РАФТ С E
function shelves.tryRestock()

    -- Без кашон не можем да зареждаме
    if delivery.carriedBox == nil then
        return false
    end

    local productName = delivery.carriedBox

    local shelf =
        shelves.getNearbyShelf(productName)

    if not shelf then
        return false
    end

    -- Определя продукта на празния рафт
    if shelf.productName == nil then
        shelf.productName = productName
    end

    -- Добавя артикулите от кашона
    shelf.quantity =
        shelf.quantity +
        shop.products[productName].itemsPerBox

    -- Премахва кашона от ръцете
    delivery.carriedBox = nil

    return true
end


-- РИСУВАНЕ НА СТОКАТА ВЪРХУ РАФТОВЕТЕ
function shelves.draw()

    if map.current ~= "assets/maps/shopmap.lua" then
        return
    end

    love.graphics.push("all")

    love.graphics.setColor(1, 1, 1, 1)

    -- Размер на визуалните артикули
    local scale = math.min(
        26 / delivery.frameWidth,
        26 / delivery.frameHeight
    )

    -- Четири позиции върху всеки рафт
    local itemPositions = {
        {-25, -24},
        {0, -24},
        {-25, 12},
        {0, 12}
    }

    for _, shelf in ipairs(shelves.list) do

        if shelf.productName ~= nil
            and shelf.quantity > 0 then

            local quad =
                shelves.itemQuads[shelf.productName]

            if quad then

                -- Рисува продуктите върху рафта
                for _, position in ipairs(itemPositions) do

                    love.graphics.draw(
                        delivery.productSheet,
                        quad,
                        shelf.x + position[1],
                        shelf.y + position[2],
                        0,
                        scale,
                        scale
                    )
                end
            end

            -- Показва количеството
            love.graphics.setFont(
                delivery.PendingWindowFont
            )

            love.graphics.print(
                tostring(shelf.quantity),
                shelf.x + 30,
                shelf.y - 49
            )
        end
    end


    -- Надпис за взаимодействие
    if delivery.carriedBox
        and not delivery.MenuOpen
        and not saveMenu.isOpen then

        local shelf =
            shelves.getNearbyShelf(delivery.carriedBox)

        if shelf then

            love.graphics.setFont(promptFont)

            love.graphics.print(
                "[E] Restock " .. delivery.carriedBox,
                player.x - 35,
                player.y - 45
            )
        end
    end

    love.graphics.pop()
end


-- ПОДГОТВЯ НАЛИЧНОСТИТЕ ЗА SQLITE
function shelves.exportInventory(existingInventory)

    local inventory = {}

    -- Запазва други данни от inventory
    for itemName, quantity in pairs(existingInventory or {}) do

        if type(itemName) == "string"
            and not itemName:match("^shelf_%d+_") then

            inventory[itemName] = quantity
        end
    end

    -- Записва количеството на всеки зареден рафт
    for _, shelf in ipairs(shelves.list) do

        if shelf.productName ~= nil
            and shelf.quantity > 0 then

            local key =
                "shelf_" ..
                shelf.id ..
                "_" ..
                shelf.productName

            inventory[key] = shelf.quantity
        end
    end

    return inventory
end


-- ВЪЗСТАНОВЯВА НАЛИЧНОСТИТЕ ОТ SQLITE
function shelves.loadFromInventory(inventory)

    inventory = inventory or {}

    -- Изчиства предишните наличности
    for _, shelf in ipairs(shelves.list) do

        shelf.productName = nil
        shelf.quantity = 0

        -- Проверява записаните продукти
        for _, productName in ipairs(delivery.products) do

            local key =
                "shelf_" ..
                shelf.id ..
                "_" ..
                productName

            local quantity =
                tonumber(inventory[key]) or 0

            if quantity > 0 then

                shelf.productName = productName
                shelf.quantity = math.floor(quantity)

                break
            end
        end
    end
end


return shelves
