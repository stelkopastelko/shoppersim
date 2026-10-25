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


-- produktite v reda, v koito shte se pokazvat
delivery.products = {
    "apple",
    "bread",
    "cheese",
    "jam"
}


function delivery.load()

    -- font
    delivery.menuFont = love.graphics.newFont(
        "assets/fontove/deliveryMenuFont.ttf",
        32
    )


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
    
    local mouseX, mouseY = love.mouse.getPosition()

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


if isHovering == true then
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
    if delivery.MenuOpen == true then
        love.mouse.setCursor(delivery.NormalCursor)
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
          love.graphics.setColor(0,0,0,0.3)
          love.graphics.rectangle("fill", delivery.Menu.x + 15, delivery.Menu.y + 15,delivery.Menu.width, delivery.Menu.height, 18, 18)
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