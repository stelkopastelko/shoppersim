require("player") -- zarejda player.lua
require("npc")    -- zarejda npc.lua
require("shop")   -- zarejda shop.lua
require("customer")
require("map")
local wf = require("libraries/windfield") -- zarejda Windfield bibliotekata


-- razmer na prozoreca
SCREEN_WIDTH = 1920 -- shirochina na igrata
SCREEN_HEIGHT = 1080 -- visochina na igrata


function love.load() -- izpulnqva se vednuj pri startirane na igrata
   love.graphics.setDefaultFilter("nearest", "nearest")
    -- Full HD rezoluciq
    love.window.setMode(
        SCREEN_WIDTH, -- shirochina na prozoreca
        SCREEN_HEIGHT -- visochina na prozoreca
    )


    -- pravq physics world bez gravitaciq
    world = wf.newWorld(
        0, -- gravitaciq po X
        0  -- gravitaciq po Y
    )


    -- zarejdam sistemite
    npc.load() -- zarejda promenlivite na npc-to

    shop.load() -- zarejda magazina i sprite-ovete na stokite

    player.load(world) -- zarejda player-a i mu podava physics world-a
    
    map.load(world)

    -- tablica v koqto pazq granicite na mapata
    walls = {}


    -- gorna granica
    walls.top = world:newRectangleCollider(
        -10, -- X poziciq
        -20, -- Y poziciq, malko izvun ekrana
        SCREEN_WIDTH, -- shirochina na stenata
        20 -- visochina na stenata
    )

    -- stenata ne moje da se dviji
    walls.top:setType("static")


    -- dolna granica
    walls.bottom = world:newRectangleCollider(
        -10, -- X poziciq
        SCREEN_HEIGHT, -- zapochva sled dolniq krai na ekrana
        SCREEN_WIDTH, -- shirochina na stenata
        20 -- visochina na stenata
    )

    -- stenata ne moje da se dviji
    walls.bottom:setType("static")


    -- lqva granica
    walls.left = world:newRectangleCollider(
        -20, -- stoi izvun lqvata strana na ekrana
        -10, -- Y poziciq
        20, -- shirochina na stenata
        SCREEN_HEIGHT -- visochina kolkoto celiq ekran
    )

    -- stenata ne moje da se dviji
    walls.left:setType("static")


    -- dqsna granica
    walls.right = world:newRectangleCollider(
        SCREEN_WIDTH, -- zapochva sled desniq krai na ekrana
        -10, -- Y poziciq
        20, -- shirochina na stenata
        SCREEN_HEIGHT -- visochina kolkoto celiq ekran
    )

    -- stenata ne moje da se dviji
    walls.right:setType("static")

end


function love.update(dt) -- izpulnqva se vseki frame
       customer.update(dt)
    -- player.update izchislqva dvijenieto i animaciite
    player.update(dt)


    -- update-vam physics world-a
    -- tuk Windfield realno mestи collider-ite i smqta collision-ite
    world:update(dt)


    -- vzimam X poziciqta na collider-a
    -- i q prevrushtam v poziciq za sprite-a
    player.x = player.collider:getX() - player.width / 2

    -- sushtoto za Y poziciqta
    player.y = player.collider:getY() - player.height / 2


    -- update-vam npc-to sled kato veche znam novata poziciq na player-a
    npc.update()

end


function love.draw() -- risuva vsichko vseki frame
     map.draw()
    customer.draw()
    player.draw() -- risuva player-a

    npc.draw() -- risuva npc-to i dialogue UI-to

    shop.draw() -- risuva stokite / shop obektite

    -- pokazva physics collider-ite
    -- tova e samo za test dokato pravim collision-a
    world:draw()

end


function love.keypressed(key) -- izpulnqva se vednuj pri natiskane na klavish

    -- proverqva dali player-a e do npc-to
    -- i dali e natisnal E
    if npc.canIinteract == true and key == "e" then


        -- ako razgovora oshte ne e zapochnal
        if npc.interacted == false then

            -- otvarqm razgovora
            npc.interacted = true


        else

            -- proverqvam dali ne sme na poslednata replika
            if npc.dialogueStep < #dialogues.introOrder then


                -- ako v momenta govori npc-to
                if npc.currentspeaker == "npc" then

                    -- minavam na sledvashtata npc replika
                    npc.currentLine = npc.currentLine + 1

                else

                    -- ako govori player-a
                    -- minavam na sledvashtata negova replika
                    npc.playerLine = npc.playerLine + 1

                end


                -- minavam na sledvashtata stupka ot celiq razgovor
                npc.dialogueStep = npc.dialogueStep + 1


                -- proverqvam koi govori na novata stupka
                npc.currentspeaker =
                    dialogues.introOrder[npc.dialogueStep]


            else

                -- ako nqma poveche repliki zatvarqm razgovora
                npc.interacted = false


                -- vrushtam npc replikite v nachaloto
                npc.currentLine = 1

                -- vrushtam player replikite v nachaloto
                npc.playerLine = 1

                -- vrushtam celiq razgovor na purvata stupka
                npc.dialogueStep = 1

                -- purvi vinagi zapochva npc-to
                npc.currentspeaker = "npc"

            end

        end

    end

end