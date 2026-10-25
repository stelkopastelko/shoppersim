delivery = {}

delivery.MenuOpen = false


-- menu
delivery.Menu = {
    x = 260,
    y = 120,
    width = 1400,
    height = 840
}


-- apple card
delivery.appleCard = {
    x = delivery.Menu.x + 80,
    y = delivery.Menu.y + 140,
    width = 1240,
    height = 150
}


-- apple order button
delivery.appleButton = {
    x = delivery.appleCard.x + 1030,
    y = delivery.appleCard.y + 41,
    width = 180,
    height = 55
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


    -- razmeri na celiq spritesheet
    local sheetWidth =
        delivery.productSheet:getWidth()

    local sheetHeight =
        delivery.productSheet:getHeight()


    -- razmer na edna kletka
    delivery.frameWidth =
        sheetWidth / 4

    delivery.frameHeight =
        sheetHeight / 2


    -- apple box
    delivery.appleBoxQuad =
        love.graphics.newQuad(
            0,
            delivery.frameHeight,
            delivery.frameWidth,
            delivery.frameHeight,
            sheetWidth,
            sheetHeight
        )

end


function delivery.draw()

    if delivery.MenuOpen == true then


        -- zatumnqvane na fona
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


        -- apple card
        love.graphics.setColor(
            225 / 255,
            210 / 255,
            240 / 255
        )

        love.graphics.rectangle(
            "fill",
            delivery.appleCard.x,
            delivery.appleCard.y,
            delivery.appleCard.width,
            delivery.appleCard.height,
            14,
            14
        )


        -- apple box sprite
        love.graphics.setColor(
            1,
            1,
            1,
            1
        )

        love.graphics.draw(
            delivery.productSheet,
            delivery.appleBoxQuad,
            delivery.appleCard.x + 15,
            delivery.appleCard.y + 15,
            0,
            0.3,
            0.3
        )


        -- apple text
        love.graphics.setColor(
            150 / 255,
            115 / 255,
            180 / 255
        )

        love.graphics.print(
            shop.products.apple.name,
            delivery.appleCard.x + 300,
            delivery.appleCard.y + 55
        )

        love.graphics.print(
            shop.products.apple.itemsPerBox .. " items",
            delivery.appleCard.x + 550,
            delivery.appleCard.y + 55
        )

        love.graphics.print(
            "$" .. shop.products.apple.boxPrice,
            delivery.appleCard.x + 900,
            delivery.appleCard.y + 55
        )


        -- apple order button
        love.graphics.rectangle(
            "fill",
            delivery.appleButton.x,
            delivery.appleButton.y,
            delivery.appleButton.width,
            delivery.appleButton.height,
            10,
            10
        )

            -- reset color
    love.graphics.setColor(
        1,
        1,
        1,
        1
    )
        love.graphics.print("Order", delivery.appleButton.x + 17 , delivery.appleButton.y + 10)

    end


    -- reset color
    love.graphics.setColor(
        1,
        1,
        1,
        1
    )
  
end