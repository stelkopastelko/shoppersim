local anim8 = require("libraries/anim8")

player = {}

-- poziciq i razmer na player-a
player.x = 300
player.y = 300
player.width = 30
player.height = 20

-- skorost na dvijenie
player.speed = 300

-- pari
player.money = 100  

-- durji li neshto geroqt
player.hold = false
player.helditem = nil


function player.load(world)

    -- pravq collider-a na player-a
    player.collider = world:newRectangleCollider(
        player.x + player.width / 2,
        player.y + player.height / 2,
        player.width,
        player.height
    )
       player.spriteOffsetX = 88
        player.spriteOffsetY = 150
    -- ne pozvolqva collider-a da se vurti
    player.collider:setFixedRotation(true)

    -- posokata v koqto gleda player-a
    player.direction = "down"

    -- zarejdam spritesheet-a
    player.spritesheet = love.graphics.newImage(
        "assets/playersprite.png"
    )

    -- razdelqm spritesheet-a na frame-ove
    player.grid = anim8.newGrid(
        176,
        160,
        player.spritesheet:getWidth(),
        player.spritesheet:getHeight()
    )

    -- tablica s animaciite
    player.animations = {}

    -- idle animacii
    player.animations.idleDown =
        anim8.newAnimation(player.grid("1-6", 5), 0.15)

    player.animations.idleLeft =
        anim8.newAnimation(player.grid("1-6", 6), 0.15)

    player.animations.idleRight =
        anim8.newAnimation(player.grid("1-6", 7), 0.15)

    player.animations.idleUp =
        anim8.newAnimation(player.grid("1-6", 8), 0.15)


    -- walk animacii
    player.animations.walkDown =
        anim8.newAnimation(player.grid("1-6", 1), 0.12)

    player.animations.walkLeft =
        anim8.newAnimation(player.grid("1-6", 2), 0.12)

    player.animations.walkRight =
        anim8.newAnimation(player.grid("1-6", 3), 0.12)

    player.animations.walkUp =
        anim8.newAnimation(player.grid("1-6", 4), 0.12)


    -- animaciqta s koqto zapochva player-a
    player.currentAnimation = player.animations.idleDown

end


function player.update(dt)

    -- skorost po X i Y
    local vx = 0
    local vy = 0


    -- izbiram idle animaciq spored poslednata posoka
    if player.direction == "up" then

        player.currentAnimation = player.animations.idleUp

    elseif player.direction == "down" then

        player.currentAnimation = player.animations.idleDown

    elseif player.direction == "left" then

        player.currentAnimation = player.animations.idleLeft

    elseif player.direction == "right" then

        player.currentAnimation = player.animations.idleRight

    end


    -- dvijenie nagore
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    if love.keyboard.isDown("w") then

        vy = -player.speed

        player.currentAnimation = player.animations.walkUp
        player.direction = "up"

    end


    -- dvijenie nadolu
    if love.keyboard.isDown("s") then

        vy = player.speed

        player.currentAnimation = player.animations.walkDown
        player.direction = "down"

    end


    -- dvijenie nalqvo
    if love.keyboard.isDown("a") then

        vx = -player.speed

        player.currentAnimation = player.animations.walkLeft
        player.direction = "left"

    end


    -- dvijenie nadqsno
    if love.keyboard.isDown("d") then

        vx = player.speed

        player.currentAnimation = player.animations.walkRight
        player.direction = "right"

    end


    -- davam skorostta na collider-a
    player.collider:setLinearVelocity(vx, vy)

    -- update-vam tekushtata animaciq
    player.currentAnimation:update(dt)

end


function player.draw()

    -- risuvam tekushtata animaciq na player-a
player.currentAnimation:draw(
    player.spritesheet,
    player.collider:getX() - player.spriteOffsetX,
    player.collider:getY() - player.spriteOffsetY
)

end