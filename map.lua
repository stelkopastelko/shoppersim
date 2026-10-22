map = {}

local sti = require("libraries.sti")

function map.load(world)

    -- zarejdam mapata
    map.tiled = sti("assets/maps/shopmap.lua")

    -- tuk pazq colliderite
    map.colliders = {}

    -- minavam prez vsichki layeri
    for _, layer in ipairs(map.tiled.layers) do

        -- samo object layerite
        if layer.type == "objectgroup" then

            for _, object in ipairs(layer.objects) do

                -- ako obekta e polygon
                if object.polygon then

                    local points = {}

                    -- STI veche e slojil pravilnite koordinati
                    for _, point in ipairs(object.polygon) do

                        table.insert(points, point.x)
                        table.insert(points, point.y)

                    end

                    -- pone 3 tochki
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

                end

            end

            -- ne pokazvam polygon layerite
            layer.visible = false

        end

    end

end


function map.draw()

    map.tiled:draw()

end