shop = {}
shop.open = false
shop.item1 = {
    name = "apple",
    price = 5
}

shop.item2 = {
    name = "pear",
    price = 7
}

shop.items = {
    shop.item1,
    shop.item2
}

function shop.load()

    shop.apple = {}

    shop.applesprite = love.graphics.newImage("assets/qbulka.png")

    shop.apple.x = 200
    shop.apple.y = 300
    shop.apple.width = shop.applesprite:getWidth()
    shop.apple.height = shop.applesprite:getHeight()
end

function shop.draw ()
   if shop.open == true then 
     love.graphics.draw(shop.applesprite, shop.apple.x, shop.apple.y)
   end 
end