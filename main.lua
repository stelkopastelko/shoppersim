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

    love.graphics.setDefaultFilter(
        "nearest",
        "nearest"
    )

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
    if transitioning == false
    and delivery.MenuOpen == false then

        customer.update(dt)
        player.update(dt)
        npc.update()

    else

        -- spiram player-a
        player.collider:setLinearVelocity(
            0,
            0
        )

    end


    world:update(dt)


    -- shop map granici
    if map.current == "assets/maps/shopmap.lua" then

        local x =
            player.collider:getX()

        local y =
            player.collider:getY()


        x = math.max(
            player.width / 2,
            math.min(
                SCREEN_WIDTH - player.width / 2,
                x
            )
        )


        y = math.max(
            player.height / 2,
            math.min(
                SCREEN_HEIGHT - player.height / 2,
                y
            )
        )


        player.collider:setPosition(
            x,
            y
        )

    end


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


    -- npc.draw()
    -- customer.draw()


    -- collision debug
    world:draw()


    -- shop -> storage prompt
    if map.current == "assets/maps/shopmap.lua"
    and player.x > 185
    and player.x < 270
    and player.y > 50
    and player.y < 100
    and player.direction == "up" then

        love.graphics.setFont(
            promptFont
        )

        love.graphics.print(
            "[E] Enter Storage",
            180,
            40
        )

    end


    -- storage -> shop prompt
    if map.current == "assets/maps/storagemap.lua"
    and player.x > 910
    and player.x < 980
    and player.y > 690
    and player.y < 800
    and player.direction == "down" then

        love.graphics.setFont(
            promptFont
        )

        love.graphics.print(
            "[E] Enter Shop",
            961,
            697
        )

    end


    -- money
    love.graphics.setFont(
        promptFont
    )

    love.graphics.print(
        "$" .. player.money,
        20,
        20
    )


    -- delivery menu
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


    -- reset color
    love.graphics.setColor(
        1,
        1,
        1,
        1
    )

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

            if npc.dialogueStep
            < #dialogues.introOrder then


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
    and player.x > 177
    and player.x < 280
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


    -- delivery menu
    if key == "tab" then

        delivery.MenuOpen =
            not delivery.MenuOpen

    end


    if key == "escape"
    and delivery.MenuOpen == true then

        delivery.MenuOpen = false

    end
end
    function love.mousepressed(x,y,button)
     delivery.mousepressed(x,y,button)

    end