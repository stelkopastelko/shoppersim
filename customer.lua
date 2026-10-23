customer = {}
customer.x = 300
customer.y = 300
customer.speed = 100
 customer.target = {}
customer.target.x = 200
customer.target.y = 250

function customer.update(dt)
    local dx = customer.target.x - customer.x
    local dy = customer.target.y - customer.y
    local distance = math.sqrt(dx * dx + dy * dy)
    local moveDistance = customer.speed * dt
    if distance > moveDistance then

    local directionX = dx / distance
    local directionY = dy / distance

    customer.x = customer.x + directionX * customer.speed * dt
    customer.y = customer.y + directionY * customer.speed * dt

    else
    customer.x = customer.target.x
    customer.y = customer.target.y
    end
end

function customer.draw()

love.graphics.rectangle("fill", customer.x, customer.y, 30,60)

end