
local anim8 = require("libraries/anim8")

player = {}

-- Позиция и размери на играча
player.x = 300
player.y = 300
player.width = 30
player.height = 2

-- Скорост на движение
player.speed = 300

-- Пари
player.money = 100

-- Състояние на играча
player.hold = false
player.helditem = nil
player.direction = "down"


-- Зареждане на играча
function player.load(world)

    -- Създаване на колизията
    player.collider = world:newRectangleCollider(
        player.x + player.width / 2,
        player.y + player.height / 2,
        player.width,
        player.height
    )

    player.collider:setFixedRotation(true)

    -- Отместване на спрайта
    player.spriteOffsetX = 88
    player.spriteOffsetY = 150

    player.direction = "down"

    -- Зареждане на spritesheet
    player.spritesheet = love.graphics.newImage(
        "assets/playersprite.png"
    )

    -- Разделяне на spritesheet на кадри
    player.grid = anim8.newGrid(
        176,
        160,
        player.spritesheet:getWidth(),
        player.spritesheet:getHeight()
    )

    -- Таблица с анимациите
    player.animations = {}


    -- ХОДЕНЕ (редове 1-4)

    player.animations.walkDown =
        anim8.newAnimation(
            player.grid("1-6", 1),
            0.12
        )

    player.animations.walkLeft =
        anim8.newAnimation(
            player.grid("1-6", 2),
            0.12
        )

    player.animations.walkRight =
        anim8.newAnimation(
            player.grid("1-6", 3),
            0.12
        )

    player.animations.walkUp =
        anim8.newAnimation(
            player.grid("1-6", 4),
            0.12
        )


    -- СТОЕНЕ НА МЯСТО (редове 5-8)

    player.animations.idleDown =
        anim8.newAnimation(
            player.grid("1-6", 5),
            0.15
        )

    player.animations.idleLeft =
        anim8.newAnimation(
            player.grid("1-6", 6),
            0.15
        )

    player.animations.idleRight =
        anim8.newAnimation(
            player.grid("1-6", 7),
            0.15
        )

    player.animations.idleUp =
        anim8.newAnimation(
            player.grid("1-6", 8),
            0.15
        )


    -- Начална анимация
    player.currentAnimation =
        player.animations.idleDown
end


-- Обновяване на играча
function player.update(dt)

    local vx = 0
    local vy = 0

    -- Проверява дали играчът носи кашон
    player.hold = delivery.carriedBox ~= nil
    player.helditem = delivery.carriedBox


    -- Движение нагоре
    if love.keyboard.isDown("w") then

        vy = -player.speed
        player.direction = "up"
    end


    -- Движение надолу
    if love.keyboard.isDown("s") then

        vy = player.speed
        player.direction = "down"
    end


    -- Движение наляво
    if love.keyboard.isDown("a") then

        vx = -player.speed
        player.direction = "left"
    end


    -- Движение надясно
    if love.keyboard.isDown("d") then

        vx = player.speed
        player.direction = "right"
    end


    -- Проверява дали играчът се движи
    local isMoving = vx ~= 0 or vy ~= 0


    -- Избира нормална анимация
    local animationType

    if isMoving then
        animationType = "walk"
    else
        animationType = "idle"
    end


    -- Посоките на анимациите
    local directionSuffixes = {
        up = "Up",
        down = "Down",
        left = "Left",
        right = "Right"
    }

    -- Например walkDown или idleLeft
    local animationName =
        animationType ..
        directionSuffixes[player.direction]


    -- Избира текущата анимация
    player.currentAnimation =
        player.animations[animationName]


    -- Движение на колизията
    player.collider:setLinearVelocity(vx, vy)

    -- Обновяване на анимацията
    player.currentAnimation:update(dt)
end


-- Рисуване на играча
function player.draw()

    love.graphics.setColor(1, 1, 1, 1)

    player.currentAnimation:draw(
        player.spritesheet,
        player.collider:getX() - player.spriteOffsetX,
        player.collider:getY() - player.spriteOffsetY
    )
end
