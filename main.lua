push = require 'push'
--this is a lablary which we need to render things when we are using virtual ratio of graphic

Class = require 'class'

require 'Paddle'
--importing paddle class from local

require 'Ball' 
--importing ball class from local


window_width = 1280
window_height = 720
--window size

virtual_width = 432
virtual_height = 243
--virtual wiindow size

paddle_speed = 200
--this will maintain the speed no matter if we have 60FPS or 120FPS

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    --by default love makes the graphic of text bad so this is to prevent from that

    love.window.setTitle('Pong Game')
    --setting the title name of the window

    math.randomseed(os.time())
    --random number genrator

    smallFont = love.graphics.newFont('font.ttf',8)
    scoreFont = love.graphics.newFont('font.ttf', 32)--giving path to font which will be used for scored, changed nothing just the size
    largeFont = love.graphics.newFont('font.ttf', 16)
    love.graphics.setFont(smallFont)--giving path to the font to the top text and setting it

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['win'] = love.audio.newSource('sounds/win.wav', 'static')
    }

    push:setupScreen(virtual_width, virtual_height, window_width,window_height, {
        fullscreen = false,
        resizable = true,
        vsync = true,
       
    })
    autoplay = true
    player1 = Paddle(10,30,5,20)
    player2 = Paddle(virtual_width - 10, virtual_height - 30,5,20)
    --the staring position of both the players and using paddle to make it globle

    
    ball= Ball(virtual_width / 2-2, virtual_height /2-2, 4,4)
    --placing the ball in the middle of the screen

    player1Score = 0
    player2Score = 0
    --the score of both player at the start of the match will be 0

    servingPlayer = 1
    --serving player will decide the direction of the ball depending on who made the score

    winningPlayer = 0

    -- the state of our game; can be any of the following:
    -- 1. 'start' (the beginning of the game, before first serve)
    -- 2. 'serve' (waiting on a key press to serve the ball)
    -- 3. 'play' (the ball is in play, bouncing between paddles)
    -- 4. 'done' (the game is over, with a victor, ready for restart)

    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
--in love dt means delta and in love it is used for time which runs in seconds
    if gameState == 'serve' then
        ball.dy = math.random(-50,50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140,200)
        end
        --whoever made the score will change the direction of the ball at the time of the serve

    elseif gameState == 'play' then

        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03 -- if the ball collies with right paddle then change x to -x and incresse the speed with 1.03
            ball.x = player1.x + 5 -- when the ball collies with right paddle then add -5 pixcels to the ball otherwise the collistion will happen for infinite time

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150) -- if the ball collies with right paddle then keep the speed same and just change direction
            else
                ball.dy = math.random(10, 150) -- otherwise keep it the same
            end
            sounds['paddle_hit']:play()
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03 -- if the ball collies with left paddle then change x direction in the opposite dirention and add speed of 1.03
            ball.x = player2.x - 4 -- when the ball collies then move the ball to 4 pixcles to left to avoid infinite colliestions
    
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150) -- if the ball collies with left paddle then keep the speed same and just change direction
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']:play()
        end
        
        if ball.y <= 0 then 
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
            -- if ball goes over the top which is -0 then keep the ball at 0 which is virtual top and just make the velocity of the ball to -dy
        end

        if ball.y >= virtual_height - 4 then
            ball.y = virtual_height - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
            -- if ball goes lower the virtual screen which is virtual_height - 4 then keep the ball at bottom which is virtual_height - 4 and just change the velocity to -dy
        end
    

        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()
        
            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
                sounds['win']:play()
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        if ball.x > virtual_width then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()

            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
                sounds['win']:play()
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

    if love.keyboard.isDown('w') then --player 1 movement 
        player1.dy = -paddle_speed
    elseif love.keyboard.isDown('s') then
        player1.dy = paddle_speed
    else
        player1.dy = 0
    end

    if love.keyboard.isDown('up') then --player 2 movement
        player2.dy = -paddle_speed
    elseif love.keyboard.isDown('down') then
        player2.dy = paddle_speed
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
        --update the ball if it is in play state
        --is the game is start then the ball will start to move
    end

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
        --exit when escapse prassed
    
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            ball:reset()

            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    --background color
    
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0 , 10, virtual_width, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, virtual_width, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, virtual_width, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, virtual_width, 'center')
    elseif gameState == 'play' then
        --no ui needed
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' ..tostring(winningPlayer).. ' wins!', 0, 10, virtual_width, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, virtual_width, 'center')
    end
    
    displayScore()

    player1:render()
    player2:render()
    --live score of players 

    ball:render()
    --rendering ball

    displayFPS()
    --showing fps (logic is down in the code)   

    push:finish()
    --virtual resolution end
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 225/225, 0, 225/225)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    -- .. is used here cause adding 2 strings (FPS and the number) is not allowed to we used this ..
end

function displayScore()    
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), virtual_width / 2 - 50, virtual_height / 3)
    love.graphics.print(tostring(player2Score), virtual_width / 2 + 30, virtual_height / 3)
end
