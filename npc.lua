require("dialogue") -- zarejdam dialogue.lua za da imam dostup do dialogues

npc = {} -- pravq tablica npc, v koqto shte pazq vsichko za npc-to


function npc.load()

    -- fontove
    -- pravq otdelni fontove za ime, dialogue i interaction text
    npc.NameFont = love.graphics.newFont(22)
    npc.DialogueFont = love.graphics.newFont(16)
    npc.interactFont = love.graphics.newFont(14)

    -- interaction promenlivi
    -- canIinteract pokazva dali player-a e dostatuchno blizo
    npc.canIinteract = false

    -- interacted pokazva dali razgovora v momenta e otvoren
    npc.interacted = false

    -- poziciq i razmer na npc
    npc.x = 600
    npc.y = 300
    npc.width = 30
    npc.height = 60

    -- ime na npc-to
    npc.name = "Old Merchant"

    -- dialogue promenlivi

    -- koi red ot npc replikite pokazvam
    npc.currentLine = 1

    -- koi red ot player replikite pokazvam
    npc.playerLine = 1

    -- na koq stupka ot celiq razgovor se namiram
    npc.dialogueStep = 1

    -- koi govori v momenta
    npc.currentspeaker = "npc"

    -- tekst za butonite dolu vdqsno
    npc.continuedialogue = "E =>"
    npc.dialogueclose = "E Close"

end


function npc.update()

    -- proverka dali player-a se zastupva s npc-to
    -- proverqvam i X i Y osite
    if player.x + player.width >= npc.x
        and player.x <= npc.x + npc.width
        and player.y + player.height >= npc.y
        and player.y <= npc.y + npc.height then

        -- ako se zastupvat, moje da se govori s npc-to
        npc.canIinteract = true

    else

        -- ako player-a se otdalechi, veche ne moje da interact-va
        npc.canIinteract = false

        -- zatvarqm razgovora
        npc.interacted = false

        -- resetvam razgovora kato se otdalechim
        -- taka sledvashtiq put zapochva ot nachalo
        npc.currentLine = 1
        npc.playerLine = 1
        npc.dialogueStep = 1
        npc.currentspeaker = "npc"

    end

end


function npc.draw()

    -- risuvam samoto npc kato pravoagalnik
    -- po-kusno tuk shte ima sprite
    love.graphics.rectangle(
        "fill",
        npc.x,
        npc.y,
        npc.width,
        npc.height
    )


    -- imeto nad npc-to
    love.graphics.setFont(npc.interactFont)

    love.graphics.print(
        npc.name,
        npc.x - 30,
        npc.y - 20
    )


    -- pokazva "Press E to Interact"
    -- samo ako sme do npc-to i razgovora oshte ne e otvoren
    if npc.canIinteract == true and npc.interacted == false then

        -- pravq teksta cherven
        love.graphics.setColor(1, 0, 0)

        love.graphics.setFont(npc.interactFont)

        love.graphics.print(
            "Press E to Interact",
            npc.x,
            npc.y - 50
        )

    end


    -- vrushtam cveta na bqlo
    love.graphics.setColor(1, 1, 1)


    -- ako razgovora e otvoren, risuvam dialogue UI-to
    if npc.interacted == true then

        -- dialogue box background
        -- tumnata kutiq v dolnata chast na ekrana
        love.graphics.setColor(
            19 / 255,
            20 / 255,
            26 / 255
        )

        love.graphics.rectangle(
            "fill",
            100,
            540,
            1080,
            170,
            10,
            10
        )


        -- dialogue text
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(npc.DialogueFont)

        -- proverqvam koi govori v momenta
        if npc.currentspeaker == "npc" then

            -- ako govori npc-to, pokazvam negovata tekushta replika
            love.graphics.printf(
                dialogues.npc1[npc.currentLine],
                260,
                570,
                900,
                "left"
            )

        else

            -- ako govori player-a, pokazvam negovata tekushta replika
            love.graphics.printf(
                dialogues.player[npc.playerLine],
                260,
                570,
                900,
                "left"
            )

        end


        -- name box background
        -- malkata kutiq nad dialogue box-a
        love.graphics.setColor(
            19 / 255,
            20 / 255,
            26 / 255
        )

        love.graphics.rectangle(
            "fill",
            100,
            500,
            200,
            30,
            10,
            10
        )


        -- debelina na ramkite
        love.graphics.setLineWidth(3)


        -- name box border
        love.graphics.setColor(
            76 / 255,
            80 / 255,
            105 / 255
        )

        love.graphics.rectangle(
            "line",
            100,
            500,
            200,
            30,
            10,
            10
        )


        -- izbiram imeto na tozi koito govori
        love.graphics.setColor(
            5 / 255,
            19 / 255,
            48 / 255
        )

        love.graphics.setFont(npc.NameFont)

        if npc.currentspeaker == "npc" then

            -- ako govori npc-to, pokazvam negovoto ime
            love.graphics.print(
                npc.name,
                120,
                502
            )

        else

            -- ako govori player-a, pokazvam "You"
            love.graphics.print(
                "You",
                175,
                502
            )

        end


        -- ramka okolo golemiq dialogue box
        love.graphics.setColor(
            76 / 255,
            80 / 255,
            105 / 255
        )

        love.graphics.rectangle(
            "line",
            100,
            540,
            1080,
            170,
            10,
            10
        )


        -- portrait background
        -- tuk po-kusno shte risuvam portrait na geroq/npc-to
        love.graphics.setColor(
            5 / 255,
            19 / 255,
            48 / 255
        )

        love.graphics.rectangle(
            "fill",
            120,
            560,
            120,
            120,
            10,
            10
        )


        -- ramka okolo portrait-a
        love.graphics.setColor(
            76 / 255,
            80 / 255,
            105 / 255
        )

        love.graphics.rectangle(
            "line",
            120,
            560,
            120,
            120,
            10,
            10
        )


        -- liniq mejdu portrait-a i dialogue teksta
        love.graphics.line(
            250,
            560,
            250,
            690
        )


        -- continue / close
        love.graphics.setFont(npc.DialogueFont)

        -- #dialogues.introOrder dava broq na vsichki stupki v razgovora
        -- ako ne sme na poslednata, pokazvam E =>
        if npc.dialogueStep < #dialogues.introOrder then

            love.graphics.print(
                npc.continuedialogue,
                1130,
                680
            )

        else

            -- ako sme na poslednata replika, pokazvam E Close
            love.graphics.print(
                npc.dialogueclose,
                1110,
                680
            )

        end

    end


    -- resetvam neshtata za sledvashtoto risuvane
    -- setColor i setLineWidth ostavat aktivni dokato ne gi promenim
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1)

end