customer = {}
customer.x = 300
customer.y = 300
customer.speed = 100
 customer.target = {}
customer.target.x = 120
customer.target.y = 120

function customer.update(dt)

    local dx = customer.target.x - customer.x
    local dy = customer.target.y - customer.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > 0 then

    local directionX = dx / distance
    local directionY = dy / distance

    customer.x = customer.x + directionX * customer.speed * dt
    customer.y = customer.y + directionY * customer.speed * dt
    end
end

function customer.draw()

love.graphics.rectangle("fill", customer.x, customer.y, 30,60)

end