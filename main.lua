push = require 'push'

Class = require 'class'

require 'Bird'

require 'Pipe'

require 'PipePair'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local background = love.graphics.newImage('background.png')
local ground = love.graphics.newImage('ground.png')

med_font = love.graphics.newFont('flappy.ttf', 14)
font = love.graphics.newFont('flappy.ttf', 28)
lg_font = love.graphics.newFont('flappy.ttf', 36)

local backgroundScroll = 0
local groundScroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

local BACKGROUND_LOOPING_POINT = 413

local bird = Bird()

local pipePairs = {}

local spawnTimer = 0

local lastY = -PIPE_HEIGHT + math.random(80) + 20

local scrolling = true
local COUNTDOWN_TIME = 0.75

score = 0

gameState = 'title'

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Flappy Bird')

    math.randomseed(os.time())
    
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true

    if key == 'escape' then
        love.event.quit()
    end
    
    if (key == 'enter' or key == 'return') then
        if gameState == 'title' then
            gameState = 'play'
        elseif gameState == 'score' then
            gameState = 'play'
            score = 0
        end
    end
        
end


function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else 
        return false
    end
end

function love.update(dt)    
if scrolling then

    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt)
        % BACKGROUND_LOOPING_POINT
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt)
        % VIRTUAL_WIDTH

    spawnTimer = spawnTimer + dt

if gameState == 'play' then
    if spawnTimer > 2 then

        local y = math.max(-PIPE_HEIGHT + 10, 
            math.min(lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
        lastY = y

        table.insert(pipePairs, PipePair(y))
        spawnTimer = 0
    end

    bird:update(dt)

    for k, pair in pairs(pipePairs) do

        if not pair.scored then
            if pair.x + PIPE_WIDTH < bird.x then
                score = score + 1
                pair.scored = true
            end
        end

        pair:update(dt)

        for l, pipe in pairs(pair.pipes) do
            if bird:collides(pipe) then
                gameState = 'score'
            end
        end
    end

    if bird.y > VIRTUAL_HEIGHT - 40 then
        gameState = 'score'
    end
  
    for k, pair in pairs(pipePairs) do
        if pair.remove then
            table.remove(pipePairs, k)
        end
    end

end
    love.keyboard.keysPressed = {}
end
end

function love.draw()
    push:start()

    love.graphics.draw(background, -backgroundScroll, 0)

    if gameState == 'score' then
        love.graphics.setFont(font)
        love.graphics.printf('Ouch! You Lost.', 0, 64, VIRTUAL_WIDTH, 'center')

        love.graphics.setFont(med_font)
        love.graphics.printf('Score: ' .. tostring(score), 0, 100, VIRTUAL_WIDTH, 'center')

        love.graphics.printf('Press Enter to Play Again', 0, 164, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'play' then
        for k, pair in pairs(pipePairs) do 
            pair:render()
        end
    end

    if gameState == 'title' then
        love.graphics.setFont(font)
        love.graphics.printf('Flappy Bird', 0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(med_font)
        love.graphics.printf('Press Enter to play', 0, 184, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)

    if gameState == 'play' then
        bird:render()
        
        love.graphics.setFont(med_font)
        love.graphics.print('Score: ' .. tostring(score), 8, 8)
    end
    push:finish()
end