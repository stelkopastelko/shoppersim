require("player")
require("npc")
require("shop")
require("customer")
require("map")
require("delivery")
local wf = require("libraries/windfield")


-- screen
SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080


-- map transition
transitionAlpha = 0
transitioning = false
transitionSpeed = 2
transitionDirection = 1

nextMap = nil
nextX = 0
nextY = 0


function startMapTransition(mapPath, x, y)

    if transitioning == true then
        return
    end

    transitioning = true
    transitionDirection = 1

    nextMap = mapPath
    nextX = x
    nextY = y

end


function love.load()
   promptFont = love.graphics.newFont(18)
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.window.setMode(
        SCREEN_WIDTH,
        SCREEN_HEIGHT
    )

    -- physics world
    world = wf.newWorld(0, 0)

    npc.load()
    player.load(world)
    -- starting map
    map.load(
        world,
        "assets/maps/shopmap.lua"
    )
      delivery.load()
end 


function love.update(dt)

    -- normal game update
    if transitioning == false and delivery.MenuOpen == false then

        customer.update(dt)
        player.update(dt)
        npc.update()

    else

        -- spiram player-a po vreme na transition
        player.collider:setLinearVelocity(0, 0)

    end


    world:update(dt)


    -- player position
    player.x =
        player.collider:getX()
        - player.width / 2

    player.y =
        player.collider:getY()
        - player.height / 2


    -- fade transition
    if transitioning == true then

        -- fade out
        if transitionDirection == 1 then

            transitionAlpha =
                transitionAlpha
                + transitionSpeed * dt


            if transitionAlpha >= 1 then

                transitionAlpha = 1

                map.changeMap(
                    world,
                    nextMap
                )

                player.collider:setPosition(
                    nextX,
                    nextY
                )

                transitionDirection = -1

            end


        -- fade in
        elseif transitionDirection == -1 then

            transitionAlpha =
                transitionAlpha
                - transitionSpeed * dt


            if transitionAlpha <= 0 then

                transitionAlpha = 0
                transitioning = false
                transitionDirection = 1

                nextMap = nil

            end

        end

    end

end


function love.draw()
   
    map.draw()
    
    player.draw()

     --npc.draw()
    -- customer.draw()



    -- collision debug
    world:draw()
     

         if  map.current == "assets/maps/shopmap.lua"
    and player.x > 185
    and player.x < 270
    and player.y > 50
    and player.y < 100
    and player.direction == "up"
     then
        love.graphics.setFont(promptFont)
    love.graphics.print('[E] Enter Storage', 180, 40)
    end

    if map.current == "assets/maps/storagemap.lua"
    and player.x > 910
    and player.x < 980
    and player.y > 690
    and player.y < 800
      and player.direction == "down"
       then
        love.graphics.setFont(promptFont)
    love.graphics.print('[E] Enter Shop', 961, 697)
    end
         love.graphics.setFont(promptFont)
    love.graphics.print("$".. player.money,20, 20)
       delivery.draw()
    -- fade overlay
    love.graphics.setColor(
        0,
        0,
        0,
        transitionAlpha
    )

    love.graphics.rectangle(
        "fill",
        0,
        0,
        SCREEN_WIDTH,
        SCREEN_HEIGHT
    )

    love.graphics.setColor(1, 1, 1, 1)
    
end


function love.keypressed(key)

    -- bez interakcii po vreme na transition
    if transitioning == true then
        return
    end


    -- npc dialogue
    if npc.canIinteract == true
    and key == "e" then

        if npc.interacted == false then

            npc.interacted = true

        else

            if npc.dialogueStep < #dialogues.introOrder then

                if npc.currentspeaker == "npc" then

                    npc.currentLine =
                        npc.currentLine + 1

                else

                    npc.playerLine =
                        npc.playerLine + 1

                end

                npc.dialogueStep =
                    npc.dialogueStep + 1

                npc.currentspeaker =
                    dialogues.introOrder[
                        npc.dialogueStep
                    ]

            else

                npc.interacted = false

                npc.currentLine = 1
                npc.playerLine = 1
                npc.dialogueStep = 1

                npc.currentspeaker = "npc"

            end

        end

    end


    -- shop -> storage
    if key == "e"
    and map.current == "assets/maps/shopmap.lua"
    and player.x > 185
    and player.x < 270
    and player.y > 50
    and player.y < 100 then

        startMapTransition(
            "assets/maps/storagemap.lua",
            941,
            697
        )

        return

    end


    -- storage -> shop
    if key == "e"
    and map.current == "assets/maps/storagemap.lua"
    and player.x > 910
    and player.x < 980
    and player.y > 690
    and player.y < 800 then

        startMapTransition(
            "assets/maps/shopmap.lua",
            232,
            110
        )

        return

    end
     if key == "tab" then
        delivery.MenuOpen = not delivery.MenuOpen
     end
     if key == "escape" and delivery.MenuOpen == true then
        delivery.MenuOpen = false
     end
end