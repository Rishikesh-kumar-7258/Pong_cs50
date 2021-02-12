VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

PADDLE_HEIGHT = 32
PADDLE_WIDTH = 8
PADDLE_SPEED = 140

BALL_SIZE = 4

push = require 'push'

LARGE_FONT = love.graphics.newFont(32)
SMALL_FONT = love.graphics.newFont(16)

player1 = {
    x = 10, y = 10,
    score = 0
}

player2 = {
    x = VIRTUAL_WIDTH - PADDLE_WIDTH - 10,
    y = VIRTUAL_HEIGHT - PADDLE_HEIGHT - 10,
    score = 0
}

ball = {
    x = VIRTUAL_WIDTH/2 - BALL_SIZE / 2,
    y = VIRTUAL_HEIGHT /2 - BALL_SIZE / 2,
    dx = 0, dy = 0
}

gameState = 'title'

-- THE LOAD FUNCTION FOR THE GAME
function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT)

    resetBall()
end

-- THE DRAW FUNCTION FOR THE GAME
function love.draw()
    push:start()
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    if gameState == 'title' then
        love.graphics.setFont(LARGE_FONT)
        love.graphics.printf('Pre50 Pong', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf('Press Enter', 0,  VIRTUAL_HEIGHT - 32, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'serve' then
        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf("Press Enter to Serve!", 0 , 10, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'win' then
        love.graphics.setFont(LARGE_FONT)
        local winner = player1.score >= 3 and '1' or '2'
        love.graphics.printf('player '.. winner .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf('Press Enter to Restart' , 0 , VIRTUAL_HEIGHT - 32, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.rectangle('fill', ball.x, ball.y, BALL_SIZE, BALL_SIZE)
    love.graphics.rectangle('fill', player1.x, player1.y, PADDLE_WIDTH, PADDLE_HEIGHT)
    love.graphics.rectangle('fill', player2.x, player2.y, PADDLE_WIDTH, PADDLE_HEIGHT)

    love.graphics.setFont(LARGE_FONT)
    love.graphics.print(player1.score, VIRTUAL_WIDTH / 2 - 36, VIRTUAL_HEIGHT / 2 - 16)
    love.graphics.print(player2.score, VIRTUAL_WIDTH / 2 + 16, VIRTUAL_HEIGHT / 2 - 16)
    love.graphics.setFont(SMALL_FONT)
    push:finish()
end

-- THE KEYPRESSED FUNCTION FOR THE GAME
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'enter' or key == 'return' then
        if gameState == 'title' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'win' then
            player1.score = 0
            player2.score = 0
            gameState = 'title'
        end
    end
end

-- THE UPDATE FUNCTION FOR THE GAME
function love.update(dt)
    if love.keyboard.isDown('w') then
        player1.y = player1.y - PADDLE_SPEED * dt
    elseif love.keyboard.isDown('s') then
        player1.y = player1.y + PADDLE_SPEED * dt
    end

    if love.keyboard.isDown('up') then
        player2.y = player2.y - PADDLE_SPEED * dt
    elseif love.keyboard.isDown('down') then
        player2.y = player2.y + PADDLE_SPEED * dt
    end

    if gameState == 'play' then
        ball.x = ball.x + ball.dx * dt
        ball.y = ball.y + ball.dy * dt

        if ball.x <= 0 then
            player2.score = player2.score + 1
            resetBall()
            if player2.score >= 3 then
                gameState = 'win'
            else gameState = 'serve'
            end
        elseif ball.x >= VIRTUAL_WIDTH - BALL_SIZE then
            player1.score = player1.score + 1
            resetBall()
            if player1.score >= 3 then
                gameState = 'win'
            else gameState = 'serve'
            end
        end

        if ball.y <= 0 or ball.y >= VIRTUAL_HEIGHT - BALL_SIZE then
            ball.dy = -ball.dy * 1.02
        end

        if collides(player1, ball) then 
            ball.dx = -ball.dx *1.04
            ball.x = player1.x + PADDLE_WIDTH
        elseif collides(player2, ball) then
            ball.dx = -ball.dx * 1.04
            ball.x = player2.x - BALL_SIZE
        end

        
    end
end

--FUNCTION TO RESET THE POSTION OF THE BALL TO THE INITIAL POSITION
function resetBall()
    ball.x = VIRTUAL_WIDTH/2 - BALL_SIZE / 2
    ball.y = VIRTUAL_HEIGHT /2 - BALL_SIZE / 2

    ball.dx = 60 + math.random(60)
    if math.random(2) == 1 then
        ball.dx = -ball.dx
    end

    ball.dy = 30 + math.random(60)
    if math.random(2) == 1 then
        ball.dy = -ball.dy
    end
end

--FUNCTION TO LOOK FOR THE COLLISION BETWEEN THE BALL AND THE BOARD
function collides(p, b)
    return not (p.x > b.x + BALL_SIZE or p.y > b.y + BALL_SIZE or b.x > p.x + PADDLE_WIDTH or b.y > p.y + PADDLE_HEIGHT)
end