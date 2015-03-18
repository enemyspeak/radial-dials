
function love.run()
    if love.math then
        love.math.setRandomSeed(os.time())
    end

    if love.event then
        love.event.pump()
    end

    if love.load then love.load(arg) end

    if love.timer then love.timer.step() end

    local dt = 0

    while true do   -- game loop

        if love.event then
            love.event.pump()
            for e,a,b,c,d in love.event.poll() do
                if e == "quit" then 
                    if not love.quit or not love.quit() then
                        if love.audio then
                            love.audio.stop()
                        end
                        return
                    end
                end
                love.handlers[e](a,b,c,d)
            end
        end

        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        if love.update then love.update(dt) end 

        if love.window and love.graphics and love.window.isCreated() then
            love.graphics.clear()
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end


function love.load()
    lg= love.graphics
                require 'lib.middleclass'
    flux =      require 'lib.flux.flux'

    radialControl = require 'lua.control2'
    control = radialControl:new()
    control2 = radialControl:new({ x = lg.getWidth(), y = lg.getHeight()/2 })
    control3 = radialControl:new({ x = lg.getWidth() + lg.getWidth()/2, y = lg.getHeight()/2 })
    lg = love.graphics
end

function love.update(dt)
    flux.update(dt)
    control:update()
    control2:update()
    control3:update()
end

function love.draw()
    control:draw()
    control2:draw()
    control3:draw()
end

function love.textinput(t)
    -- hey this is bad but whatever
    control:textinput(t)
end

function love.mousepressed( x,y,button )  -- this is a callback function when the mouse is pressed
    control:mousepressed(x,y,button)
    control2:mousepressed(x,y,button)
    control3:mousepressed(x,y,button)
end

function love.mousereleased( x,y,button )  -- this is a callback function when the mouse is released
    control:mousereleased(x,y,button)
    control2:mousereleased(x,y,button)
    control3:mousereleased(x,y,button)
end

function love.keypressed(key, unicode)  -- this is a callback function when a key is pressed
    if key == 'escape' then
        love.event.push('quit')                 -- Send 'quit' even to event queue  
    end
end