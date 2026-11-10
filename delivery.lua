
require("saveMenu")

delivery = {}

delivery.MenuOpen = false

delivery.HandCursor = love.mouse.getSystemCursor("hand")
delivery.NormalCursor = love.mouse.getSystemCursor("arrow")

-- Меню за поръчки
delivery.Menu = {
    x = 260,
    y = 120,
    width = 1400,
    height = 840
}

-- Прозорец за чакащи доставки
delivery.pendingWindow = {
    x = 1600,
    y = 880,
    width = 300,
    height = 190
}

-- Продукти
delivery.products = {
    "apple",
    "bread",
    "cheese",
    "jam"
}

delivery.pendingOrders = {
    apple = 0,
    bread = 0,
    cheese = 0,
    jam = 0
}

-- Състояние на доставките
delivery.orderQueue = {}
delivery.arrivedBoxes = {}
delivery.boxColliders = {}

-- Носени и оставени кашони
delivery.carriedBox = nil
delivery.droppedBoxes = {}

-- Време за доставка
delivery.deliveryTime = 5


-- ЗАРЕЖДАНЕ
function delivery.load()

    delivery.menuFont = love.graphics.newFont(
        "assets/fontove/deliveryMenuFont.ttf",
        32
    )

    delivery.PendingWindowFont = love.graphics.newFont(
        "assets/fontove/deliveryMenuFont.ttf",
        14
    )

    delivery.productSheet = love.graphics.newImage(
        "assets/stoka.png"
    )

    local sheetWidth = delivery.productSheet:getWidth()
    local sheetHeight = delivery.productSheet:getHeight()

    delivery.frameWidth = sheetWidth / 4
    delivery.frameHeight = sheetHeight / 2

    delivery.boxQuads = {}

    for i, productName in ipairs(delivery.products) do

        delivery.boxQuads[productName] =
            love.graphics.newQuad(
                (i - 1) * delivery.frameWidth,
                delivery.frameHeight,
                delivery.frameWidth,
                delivery.frameHeight,
                sheetWidth,
                sheetHeight
            )
    end
end


-- ВЪЗСТАНОВЯВАНЕ НА ПОРЪЧКИ
function delivery.restoreOrders(orders)

    delivery.orderQueue = {}

    for productName in pairs(delivery.pendingOrders) do
        delivery.pendingOrders[productName] = 0
    end

    for _, order in ipairs(orders or {}) do

        local productName = order.productName
        local timer = order.timer

        if delivery.pendingOrders[productName] ~= nil
            and type(timer) == "number" then

            table.insert(delivery.orderQueue, {
                productName = productName,
                timer = math.max(0, timer)
            })

            delivery.pendingOrders[productName] =
                delivery.pendingOrders[productName] + 1
        end
    end
end


-- ОБНОВЯВАНЕ НА ДОСТАВКИТЕ
function delivery.update(dt)

    for i = #delivery.orderQueue, 1, -1 do

        local order = delivery.orderQueue[i]

        if order.timer > 0 then
            order.timer = math.max(0, order.timer - dt)
        end

        if order.timer <= 0 then

            -- Добавя пристигнал кашон
            table.insert(
                delivery.arrivedBoxes,
                order.productName
            )

            -- Колизия, ако играчът е в склада
            if map.current == "assets/maps/storagemap.lua" then

                delivery.createBoxColliders(
                    #delivery.arrivedBoxes,
                    world
                )
            end

            table.remove(delivery.orderQueue, i)

            delivery.pendingOrders[order.productName] =
                delivery.pendingOrders[order.productName] - 1
        end
    end
end


-- РИСУВАНЕ НА ПРОДУКТ В МЕНЮТО
function delivery.drawProduct(productName, index)

    local product = shop.products[productName]

    local cardX = delivery.Menu.x + 80
    local cardY = delivery.Menu.y + 140
        + (index - 1) * 170

    local cardWidth = 1240
    local cardHeight = 150

    local mouseX, mouseY = love.mouse.getPosition()

    -- Фон
    love.graphics.setColor(
        225 / 255,
        210 / 255,
        240 / 255
    )

    love.graphics.rectangle(
        "fill",
        cardX,
        cardY,
        cardWidth,
        cardHeight,
        14,
        14
    )

    -- Кашон
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.draw(
        delivery.productSheet,
        delivery.boxQuads[productName],
        cardX + 15,
        cardY + 15,
        0,
        0.3,
        0.3
    )

    love.graphics.setFont(delivery.menuFont)

    love.graphics.setColor(
        150 / 255,
        115 / 255,
        180 / 255
    )

    -- Име
    love.graphics.print(
        product.name,
        cardX + 300,
        cardY + 55
    )

    -- Количество
    love.graphics.print(
        product.itemsPerBox .. " items",
        cardX + 550,
        cardY + 55
    )

    -- Цена
    love.graphics.print(
        "$" .. product.boxPrice,
        cardX + 900,
        cardY + 55
    )

    -- Бутон Order
    local buttonX = cardX + 1030
    local buttonY = cardY + 41

    local buttonWidth = 180
    local buttonHeight = 55

    local isHovering =
        mouseX >= buttonX
        and mouseX <= buttonX + buttonWidth
        and mouseY >= buttonY
        and mouseY <= buttonY + buttonHeight

    if player.money < product.boxPrice then

        love.graphics.setColor(
            120 / 255,
            111 / 255,
            128 / 255
        )

    elseif isHovering then

        love.mouse.setCursor(delivery.HandCursor)

        love.graphics.setColor(
            155 / 255,
            120 / 255,
            190 / 255
        )

    else

        love.graphics.setColor(
            135 / 255,
            100 / 255,
            170 / 255
        )
    end

    love.graphics.rectangle(
        "fill",
        buttonX,
        buttonY,
        buttonWidth,
        buttonHeight,
        10,
        10
    )

    love.graphics.setColor(
        245 / 255,
        235 / 255,
        250 / 255
    )

    love.graphics.print(
        "Order",
        buttonX + 14,
        buttonY + 14
    )
end


-- ПРОЗОРЕЦ С ЧАКАЩИ ДОСТАВКИ
function delivery.drawPendingWindow()

    -- Фон
    love.graphics.setColor(
        185 / 255,
        165 / 255,
        210 / 255
    )

    love.graphics.rectangle(
        "fill",
        delivery.pendingWindow.x,
        delivery.pendingWindow.y,
        delivery.pendingWindow.width,
        delivery.pendingWindow.height,
        12,
        12
    )

    -- Рамка
    love.graphics.setColor(
        105 / 255,
        80 / 255,
        140 / 255
    )

    love.graphics.rectangle(
        "line",
        delivery.pendingWindow.x,
        delivery.pendingWindow.y,
        delivery.pendingWindow.width,
        delivery.pendingWindow.height,
        12,
        12
    )

    love.graphics.setFont(delivery.PendingWindowFont)

    love.graphics.print(
        "Pending Deliveries",
        delivery.pendingWindow.x + 23,
        delivery.pendingWindow.y + 10
    )

    -- Брой поръчани кашони
    for i, productName in ipairs(delivery.products) do

        local boxX = delivery.pendingWindow.x + 25
        local boxY = delivery.pendingWindow.y + 35
            + (i - 1) * 37

        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.draw(
            delivery.productSheet,
            delivery.boxQuads[productName],
            boxX,
            boxY,
            0,
            0.10,
            0.10
        )

        love.graphics.print(
            delivery.pendingOrders[productName],
            boxX + 50,
            boxY + 14
        )
    end
end


-- ГЛАВНО МЕНЮ ЗА ДОСТАВКИ
function delivery.draw()

    love.graphics.push("all")

    love.mouse.setCursor(delivery.NormalCursor)

    if not delivery.MenuOpen and not saveMenu.isOpen then
        delivery.drawPendingWindow()
    end

    if delivery.MenuOpen then

        -- Затъмняване
        love.graphics.setColor(0, 0, 0, 0.45)

        love.graphics.rectangle(
            "fill",
            0,
            0,
            SCREEN_WIDTH,
            SCREEN_HEIGHT
        )

        -- Сянка
        love.graphics.setColor(0, 0, 0, 0.3)

        love.graphics.rectangle(
            "fill",
            delivery.Menu.x + 15,
            delivery.Menu.y + 15,
            delivery.Menu.width,
            delivery.Menu.height,
            18,
            18
        )

        -- Фон
        love.graphics.setColor(
            205 / 255,
            185 / 255,
            225 / 255
        )

        love.graphics.rectangle(
            "fill",
            delivery.Menu.x,
            delivery.Menu.y,
            delivery.Menu.width,
            delivery.Menu.height,
            18,
            18
        )

        -- Рамка
        love.graphics.setColor(
            95 / 255,
            65 / 255,
            135 / 255
        )

        love.graphics.setLineWidth(4)

        love.graphics.rectangle(
            "line",
            delivery.Menu.x,
            delivery.Menu.y,
            delivery.Menu.width,
            delivery.Menu.height,
            18,
            18
        )

        -- Заглавие
        love.graphics.setFont(delivery.menuFont)

        love.graphics.setColor(
            75 / 255,
            45 / 255,
            105 / 255
        )

        love.graphics.print(
            "Order Stock",
            delivery.Menu.x + 530,
            delivery.Menu.y + 20
        )

        -- Пари
        love.graphics.setColor(
            150 / 255,
            115 / 255,
            180 / 255
        )

        love.graphics.print(
            "$" .. player.money,
            delivery.Menu.x + 30,
            delivery.Menu.y + 20
        )

        -- Продукти
        for i, productName in ipairs(delivery.products) do
            delivery.drawProduct(productName, i)
        end
    end

    love.graphics.pop()
end


-- ПОРЪЧВАНЕ С МИШКАТА
function delivery.mousepressed(x, y, button)

    if not delivery.MenuOpen or button ~= 1 then
        return
    end

    for i, productName in ipairs(delivery.products) do

        local cardX = delivery.Menu.x + 80
        local cardY = delivery.Menu.y + 140
            + (i - 1) * 170

        local buttonX = cardX + 1030
        local buttonY = cardY + 41

        local buttonWidth = 180
        local buttonHeight = 55

        local product = shop.products[productName]

        if x >= buttonX
            and x <= buttonX + buttonWidth
            and y >= buttonY
            and y <= buttonY + buttonHeight then

            if player.money >= product.boxPrice then

                -- Плаща за кашона
                player.money =
                    player.money - product.boxPrice

                -- Увеличава броя чакащи доставки
                delivery.pendingOrders[productName] =
                    delivery.pendingOrders[productName] + 1

                -- Създава поръчка с таймер
                table.insert(delivery.orderQueue, {
                    productName = productName,
                    timer = delivery.deliveryTime
                })
            end

            return
        end
    end
end


-- РИСУВА ПРИСТИГНАЛИТЕ КАШОНИ
function delivery.DrawArrivedBoxes()

    for i, productName in ipairs(delivery.arrivedBoxes) do

        local boxX = 1112 + (i - 1) * 60
        local boxY = 409

        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.draw(
            delivery.productSheet,
            delivery.boxQuads[productName],
            boxX,
            boxY,
            0,
            0.15,
            0.15
        )
    end
end


-- КОЛИЗИИ НА ПРИСТИГНАЛИТЕ КАШОНИ
function delivery.createBoxColliders(i, world)

    if delivery.boxColliders[i] then
        return
    end

    local boxX = 1112 + (i - 1) * 60
    local boxY = 409

    local collider = world:newRectangleCollider(
        boxX + 13,
        boxY + 8,
        43,
        45
    )

    collider:setType("static")

    delivery.boxColliders[i] = collider
end


-- ПРЕМАХВА КОЛИЗИИТЕ НА ДОСТАВКИТЕ
function delivery.clearBoxColliders()

    for _, collider in pairs(delivery.boxColliders) do
        collider:destroy()
    end

    delivery.boxColliders = {}
end


-- НАМИРА БЛИЗЪК ПРИСТИГНАЛ КАШОН
function delivery.getNearbyBox()

    local playerX, playerY =
        player.collider:getPosition()

    local closestIndex = nil
    local closestDistance = 50

    for i, collider in pairs(delivery.boxColliders) do

        local boxX, boxY = collider:getPosition()

        local distance = math.sqrt(
            (playerX - boxX)^2 +
            (playerY - boxY)^2
        )

        if distance <= closestDistance then

            closestDistance = distance
            closestIndex = i
        end
    end

    if closestIndex then
        return closestIndex, delivery.arrivedBoxes[closestIndex]
    end

    return nil, nil
end


-- СЪЗДАВА КОЛИЗИЯ НА ОСТАВЕН КАШОН
function delivery.createDroppedBoxCollider(box, world)

    if box.collider then
        return
    end

    local width = 43
    local height = 45

    box.collider = world:newRectangleCollider(
        box.x - width / 2,
        box.y - height / 2,
        width,
        height
    )

    box.collider:setType("static")
end


-- ПРЕМАХВА КОЛИЗИИТЕ НА ОСТАВЕНИТЕ КАШОНИ
function delivery.clearDroppedBoxColliders()

    for _, box in ipairs(delivery.droppedBoxes) do

        if box.collider then
            box.collider:destroy()
            box.collider = nil
        end
    end
end


-- ВЪЗСТАНОВЯВА КОЛИЗИИТЕ ПРИ СМЯНА НА КАРТА
function delivery.loadDroppedBoxColliders(world)

    for _, box in ipairs(delivery.droppedBoxes) do

        if box.mapPath == map.current then

            delivery.createDroppedBoxCollider(
                box,
                world
            )
        end
    end
end


-- ПУСКАНЕ НА КАШОН С Q
function delivery.dropBox()

    if delivery.carriedBox == nil then
        return
    end

    local x, y = player.collider:getPosition()

    -- Позиция пред играча
    local offset = 60

    if player.direction == "up" then
        y = y - offset

    elseif player.direction == "down" then
        y = y + offset

    elseif player.direction == "left" then
        x = x - offset

    elseif player.direction == "right" then
        x = x + offset
    end

    -- Създава оставения кашон
    local box = {
        productName = delivery.carriedBox,
        x = x,
        y = y,
        mapPath = map.current
    }

    table.insert(delivery.droppedBoxes, box)

    -- Добавя физическа колизия
    delivery.createDroppedBoxCollider(box, world)

    -- Освобождава ръцете на играча
    delivery.carriedBox = nil
end


-- РИСУВА ОСТАВЕНИТЕ КАШОНИ
function delivery.drawDroppedBoxes()

    for _, box in ipairs(delivery.droppedBoxes) do

        if box.mapPath == map.current then

            local scale = 0.15

            local boxWidth =
                delivery.frameWidth * scale

            local boxHeight =
                delivery.frameHeight * scale

            love.graphics.setColor(1, 1, 1, 1)

            love.graphics.draw(
                delivery.productSheet,
                delivery.boxQuads[box.productName],
                box.x - boxWidth / 2,
                box.y - boxHeight / 2,
                0,
                scale,
                scale
            )
        end
    end
end


-- НАМИРА НАЙ-БЛИЗКИЯ ОСТАВЕН КАШОН
function delivery.getNearbyDroppedBox()

    local playerX, playerY =
        player.collider:getPosition()

    local closestIndex = nil
    local closestDistance = 75

    for i, box in ipairs(delivery.droppedBoxes) do

        -- Проверява само кашоните на текущата карта
        if box.mapPath == map.current
            and box.collider then

            local distance = math.sqrt(
                (playerX - box.x)^2 +
                (playerY - box.y)^2
            )

            if distance <= closestDistance then

                closestDistance = distance
                closestIndex = i
            end
        end
    end

    return closestIndex
end


-- ВЗЕМАНЕ НА ОСТАВЕН КАШОН
function delivery.pickUpDroppedBox(index)

    if delivery.carriedBox ~= nil then
        return false
    end

    local box = delivery.droppedBoxes[index]

    if not box or box.mapPath ~= map.current then
        return false
    end

    -- Запомня продукта
    delivery.carriedBox = box.productName

    -- Премахва колизията
    if box.collider then
        box.collider:destroy()
        box.collider = nil
    end

    -- Премахва кашона от земята
    table.remove(delivery.droppedBoxes, index)

    return true
end
