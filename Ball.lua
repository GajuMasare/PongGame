Ball = Class{}

function Ball:init(x,y,width,height)
    self.x = x 
    self.y = y 
    self.width = width
    self.height = height

    self.dy = math.random(2) == 1 and -100 or 100
    --is 2 == 1 ? if yes then 100 or -100. (2) means pick between 1 or 2
    self.dx = math.random(2) == 1 and math.random(-80, -100) or math.random(80, 100)
end

function Ball:collides(paddle)
    if self.x > paddle.x + paddle.width or -- if the paddle x postion eg.205 and paddle width eg.10 and ball x(eg. 216) > both then return false (205 + 10 = 215) x given is 216 o return false 
       paddle.x > self.x + self.width then -- if the ball x postion eg. 200 and ball width which is 4 if > paddle x which is 200 (200+4=204 which is > 200) then return false
        return false
    end

    if self.y > paddle.y + paddle.height or -- if the paddle y postion (eg.20) + paddle height (eg. 10) is greater then ball y (eg.32) then return false 
       paddle.y > self.y + self.height then -- if ball y postion (eg.50) + ball height (eg.4) > paddle (eg.40) then return false
        return false
    end

    return true -- if both cases dont satisfy
end

function Ball:reset()
    self.x = virtual_width / 2-2
    self.y = virtual_height / 2-2
    self.dy = math.random(2) == 1 and -100 or 100
    self.dx = math.random(-50, 50)
    --on first 2 line we set the ball at middle
    --on last 2 line we set the ball in randome speed at both axis
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
    --adding velocity to the ball using delta time
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end


