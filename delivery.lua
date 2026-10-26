delivery = {}

delivery.MenuOpen = false

delivery.HandCursor = love.mouse.getSystemCursor("hand")
delivery.NormalCursor = love.mouse.getSystemCursor("arrow")


-- menu
delivery.Menu = {
    x = 260,
    y = 120,
    width = 1400,
    height = 840
}


-- pending orders window
delivery.pendingWindow = {
    x = 1420,
    y = 880,
    width = 480,
    height = 190
}


-- produktite v reda, v koito shte se pokazvat
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


function delivery.load()
      
    -- font
    delivery.menuFont = love.graphics.newFont(
        "assets/fontove/deliveryMenuFont.ttf",
        32
    )
     
    delivery.PendingWindowFont =  love.graphics.newFont("assets/fontove/deliveryMenuFont.ttf", 20)

    -- spritesheet
    delivery.productSheet = love.graphics.newImage(
        "assets/stoka.png"
    )


    -- razmeri na spritesheeta
    local sheetWidth =
        delivery.productSheet:getWidth()

    local sheetHeight =
        delivery.productSheet:getHeight()


    -- 4 koloni i 2 reda
    delivery.frameWidth =
        sheetWidth / 4

    delivery.frameHeight =
        sheetHeight / 2


    -- kutiite sa na vtoriq red
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


function delivery.drawProduct(productName, index)

    local product =
        shop.products[productName]


    -- poziciq na reda
    local cardX =
        delivery.Menu.x + 80

    local cardY =
        delivery.Menu.y + 140
        + (index - 1) * 170

    local cardWidth = 1240
    local cardHeight = 150


    local mouseX, mouseY =
        love.mouse.getPosition()


    -- fon na reda
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


    -- sprite
    love.graphics.setColor(
        1,
        1,
        1,
        1
    )

    love.graphics.draw(
        delivery.productSheet,
        delivery.boxQuads[productName],
        cardX + 15,
        cardY + 15,
        0,
        0.3,
        0.3
    )


    -- tekst
    love.graphics.setFont(
        delivery.menuFont
    )

    love.graphics.setColor(
        150 / 255,
        115 / 255,
        180 / 255
    )


    -- ime
    love.graphics.print(
        product.name,
        cardX + 300,
        cardY + 55
    )


    -- broiki
    love.graphics.print(
        product.itemsPerBox .. " items",
        cardX + 550,
        cardY + 55
    )


    -- cena
    love.graphics.print(
        "$" .. product.boxPrice,
        cardX + 900,
        cardY + 55
    )


    -- order button
    local buttonX =
        cardX + 1030

    local buttonY =
        cardY + 41

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

    elseif isHovering == true then

        love.mouse.setCursor(
            delivery.HandCursor
        )

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


    -- order text
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


function delivery.draw()

    -- pending orders window
    if delivery.MenuOpen == false then

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


        -- ramka
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
        love.graphics.print("Pending Deliveries", delivery.pendingWindow.x + 70, delivery.pendingWindow.y + 10)

        for i, productName in ipairs(delivery.products) do
            local boxX =
    delivery.pendingWindow.x + 25
    local boxY =
    delivery.pendingWindow.y + 35
    + (i - 1) * 37
    
     love.graphics.setColor(1,1,1)

    love.graphics.draw(
    delivery.productSheet,
    delivery.boxQuads[productName],
    boxX,
    boxY,
    0,
    0.10,
    0.10
)
        end
    end


    if delivery.MenuOpen == true then

        love.mouse.setCursor(
            delivery.NormalCursor
        )


        -- zatumnqvane na igrata
        love.graphics.setColor(
            0,
            0,
            0,
            0.45
        )

        love.graphics.rectangle(
            "fill",
            0,
            0,
            SCREEN_WIDTH,
            SCREEN_HEIGHT
        )


        -- sqnka
        love.graphics.setColor(
            0,
            0,
            0,
            0.3
        )

        love.graphics.rectangle(
            "fill",
            delivery.Menu.x + 15,
            delivery.Menu.y + 15,
            delivery.Menu.width,
            delivery.Menu.height,
            18,
            18
        )


        -- fon na menuto
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


        -- ramka
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


        -- zaglavie
        love.graphics.setFont(
            delivery.menuFont
        )

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


        -- pari
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


        -- risuvame vsichki produkti
        for i, productName in ipairs(delivery.products) do

            delivery.drawProduct(
                productName,
                i
            )

        end

    end


    -- reset
    love.graphics.setColor(
        1,
        1,
        1,
        1
    )

end


function delivery.mousepressed(x, y, button)

    for i, productName in ipairs(delivery.products) do

        local cardX =
            delivery.Menu.x + 80

        local cardY =
            delivery.Menu.y + 140
            + (i - 1) * 170


        local buttonX =
            cardX + 1030

        local buttonY =
            cardY + 41

        local buttonWidth = 180
        local buttonHeight = 55


        local product =
            shop.products[productName]


        if button == 1
        and delivery.MenuOpen == true
        and x >= buttonX
        and x <= buttonX + buttonWidth
        and y >= buttonY
        and y <= buttonY + buttonHeight then


            if player.money >= product.boxPrice then

                player.money =
                    player.money - product.boxPrice

                delivery.pendingOrders[productName] =
                    delivery.pendingOrders[productName] + 1

            end

        end

    end

end