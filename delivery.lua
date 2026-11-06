
require("saveMenu")

delivery = {}

delivery.MenuOpen = false

delivery.HandCursor = love.mouse.getSystemCursor("hand")
delivery.NormalCursor = love.mouse.getSystemCursor("arrow")

-- Основно меню за поръчки
delivery.Menu = {
    x = 260,
    y = 120,
    width = 1400,
    height = 840
}

-- Прозорец с чакащите доставки
delivery.pendingWindow = {
    x = 1600,
    y = 880,
    width = 300,
    height = 190
}

-- Продуктите в менюто
delivery.products = {
    "apple",
    "bread",
    "cheese",
    "jam"
}

-- Брой чакащи кашони от всеки продукт
delivery.pendingOrders = {
    apple = 0,
    bread = 0,
    cheese = 0,
    jam = 0
}

-- Списък с всички направени поръчки
delivery.orderQueue = {}

-- Време за доставка в секунди
delivery.deliveryTime = 40

-- Зарежда шрифтовете и изображенията
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

    -- Spritesheet с 4 колони и 2 реда
    delivery.frameWidth = sheetWidth / 4
    delivery.frameHeight = sheetHeight / 2

    delivery.boxQuads = {}

    -- Кашоните са на втория ред
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

-- Възстановява доставките от запазената игра
function delivery.restoreOrders(orders)

    -- Изчиства поръчките от предишната игра
    delivery.orderQueue = {}

    -- Нулира броячите
    for productName in pairs(delivery.pendingOrders) do
        delivery.pendingOrders[productName] = 0
    end

    -- Зарежда поръчките от базата данни
    for _, order in ipairs(orders or {}) do

        local productName = order.productName
        local timer = order.timer

        -- Проверява дали продуктът и времето са валидни
        if delivery.pendingOrders[productName] ~= nil
            and type(timer) == "number" then

            -- Възстановява отделната поръчка
            table.insert(delivery.orderQueue, {
                productName = productName,
                timer = math.max(0, timer)
            })

            -- Увеличава броя на чакащите кашони
            delivery.pendingOrders[productName] =
                delivery.pendingOrders[productName] + 1
        end
    end
end

-- Обновява оставащото време на поръчките
function delivery.update(dt)

    for _, order in ipairs(delivery.orderQueue) do

        if order.timer > 0 then
            order.timer = math.max(0, order.timer - dt)
        end

    end
end

-- Рисува един продукт в менюто
function delivery.drawProduct(productName, index)

    local product = shop.products[productName]

    local cardX = delivery.Menu.x + 80
    local cardY = delivery.Menu.y + 140
        + (index - 1) * 170

    local cardWidth = 1240
    local cardHeight = 150

    local mouseX, mouseY = love.mouse.getPosition()

    -- Фон на продукта
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

    -- Изображение на кашона
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

    -- Текст за продукта
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

    -- Позиция на бутона за поръчка
    local buttonX = cardX + 1030
    local buttonY = cardY + 41

    local buttonWidth = 180
    local buttonHeight = 55

    local isHovering =
        mouseX >= buttonX
        and mouseX <= buttonX + buttonWidth
        and mouseY >= buttonY
        and mouseY <= buttonY + buttonHeight

    -- Цвят според парите и мишката
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

    -- Бутон Order
    love.graphics.rectangle(
        "fill",
        buttonX,
        buttonY,
        buttonWidth,
        buttonHeight,
        10,
        10
    )

    -- Текст на бутона
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

-- Рисува прозореца с чакащите доставки
function delivery.drawPendingWindow()

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

    -- Показва кашоните и техните количества
    for i, productName in ipairs(delivery.products) do

        local boxX = delivery.pendingWindow.x + 25
        local boxY = delivery.pendingWindow.y + 35
            + (i - 1) * 37

        local textX = boxX + 50
        local textY = boxY + 14

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
            textX,
            textY
        )
    end
end

-- Рисува менюто за доставки
function delivery.draw()

    -- Запазва цветовете, шрифта и останалите настройки
    love.graphics.push("all")

    -- Връща нормалния курсор
    love.mouse.setCursor(delivery.NormalCursor)

    -- Показва чакащите доставки извън менютата
    if not delivery.MenuOpen and not saveMenu.isOpen then
        delivery.drawPendingWindow()
    end

    if delivery.MenuOpen then

        -- Затъмнява играта
        love.graphics.setColor(0, 0, 0, 0.45)

        love.graphics.rectangle(
            "fill",
            0,
            0,
            SCREEN_WIDTH,
            SCREEN_HEIGHT
        )

        -- Сянка на менюто
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

        -- Фон на менюто
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

        -- Пари на играча
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

        -- Показва всички продукти
        for i, productName in ipairs(delivery.products) do
            delivery.drawProduct(productName, i)
        end
    end

    -- Възстановява графичните настройки
    love.graphics.pop()
end

-- Обработва поръчките чрез мишката
function delivery.mousepressed(x, y, button)

    -- Поръчва само при отворено меню и ляв клик
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

        -- Проверява дали е натиснат бутонът Order
        if x >= buttonX
            and x <= buttonX + buttonWidth
            and y >= buttonY
            and y <= buttonY + buttonHeight then

            -- Проверява дали парите са достатъчни
            if player.money >= product.boxPrice then

                -- Изважда цената
                player.money =
                    player.money - product.boxPrice

                -- Увеличава броя на чакащите кашони
                delivery.pendingOrders[productName] =
                    delivery.pendingOrders[productName] + 1

                -- Добавя нова поръчка с отделен таймер
                table.insert(delivery.orderQueue, {
                    productName = productName,
                    timer = delivery.deliveryTime
                })
            end

            return
        end
    end
end
