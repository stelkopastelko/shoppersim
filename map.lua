map = {}

local sti = require("libraries.sti")


function map.load(world, mapPath)

    -- zarejdam mapata
    map.tiled = sti(mapPath)

    -- pazq koq mapa e zaredena
    map.current = mapPath

    -- tuk pazq colliderite
    map.colliders = {}

    -- minavam prez vsichki layeri
    for _, layer in ipairs(map.tiled.layers) do

        -- samo object layerite
        if layer.type == "objectgroup" then

            -- minavam prez vsichki obekti
            for _, object in ipairs(layer.objects) do

                -- ako obekta e polygon
                if object.polygon then

                    local points = {}

                    -- vzimam vsichki tochki na polygona
                    for _, point in ipairs(object.polygon) do
                        table.insert(points, point.x)
                        table.insert(points, point.y)
                    end

                    -- trqbvat pone 3 tochki
                    if #points >= 6 then

                        local collider =
                            world:newChainCollider(
                                true,
                                points
                            )

                        collider:setType("static")

                        table.insert(
                            map.colliders,
                            collider
                        )

                    end

                -- ako obekta e rectangle
                elseif object.width > 0 and object.height > 0 then

                    local collider =
                        world:newRectangleCollider(
                            object.x,
                            object.y,
                            object.width,
                            object.height
                        )

                    collider:setType("static")

                    table.insert(
                        map.colliders,
                        collider
                    )

                end

            end

            -- skriwam object layerite
            layer.visible = false

        end

    end

end


function map.ClearColliders()

    -- mahvam starite collideri
    for _, collider in ipairs(map.colliders) do
        collider:destroy()
    end

    -- izprazvam tablicata
    map.colliders = {}

end


function map.changeMap(world, mapPath)

    -- mahvam collisiona na starata mapa
    map.ClearColliders()

    -- zarejdam novata mapa
    map.load(world, mapPath)

end


function map.draw()

    -- risuvam tekushtata mapa
    map.tiled:draw()

end