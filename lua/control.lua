RadialControl = class('RadialControl')

RadialControl.static.FONT = love.graphics.newFont('res/tenby-five.otf',84)
RadialControl.static.FONT2 = love.graphics.newFont('res/tenby-five.otf',24)

function RadialControl:initialize(attributes)
	local attributes = attributes or {}
	self.x = attributes.x or love.graphics.getWidth()/2
	self.y = attributes.y or love.graphics.getHeight()/2
	self.r = attributes.r or 100
	self.arcTween = {
					startAngle = math.rad(-68),
					stopAngle = math.rad(-68),
					r = 255,
					g = 0,
					b = 0
					} 

	self.lineWidth = 15
	self.padding = -5
	self.numSegments = 40
	self.value = 0
	self.currentValue = self.value
	self.ghostAngle = math.rad(-68)
	self.numberEntry = false
end

function RadialControl:mapValue(value,low,high,mapLow,mapHigh) 
	return ((mapHigh - mapLow) * (value / (high - low))) + mapLow
end

function RadialControl:setAngle()
	local colorValue = math.floor(RadialControl:mapValue(math.deg(self.ghostAngle + math.pi),112,428,-90,255-90))

	flux.to(self.arcTween,0.25,{stopAngle = self.ghostAngle},"inOutQuad" )
	flux.to(self.arcTween,0.25,{r = 255-colorValue, g = colorValue, b = 0},"inOutQuad" )
end

function RadialControl:updateArc( ... )
	if self.mouseClicked then
		local mx,my = love.mouse.getPosition()
		local P = 	{
					x = mx,
					y = my
					}
		local C = 	{
					x = self.x,
					y = self.y
					}
		local tempX = P.x - C.x
		local tempY = P.y - C.y
		
		local temp = math.atan2(tempY,tempX) + math.pi/2
	
		if math.deg(temp) < -68 and math.deg(temp) >= -90 then
			temp = math.rad(-68)
			elseif math.deg(temp) > 248 and math.deg(temp) <= 270 then
			temp = math.rad(248)
		end 

		self.ghostAngle = temp
		self:setAngle() 	-- instant mode...!
--		self.mouseClicked = false
	end
end




function RadialControl:updateNumber()
	self.value = math.floor(self:mapValue(math.deg(self.arcTween.stopAngle + math.pi),112,428,-35,100-35))
end

function RadialControl:updateGhostNumber()
	self.currentValue = math.floor(self:mapValue(math.deg(self.ghostAngle + math.pi),112,428,-35,100-35))
end

function RadialControl:drawCircle()
	local originalWidth = lg.getLineWidth()
	lg.setLineWidth(1)
	lg.setColor(128,128,128)	

	lg.line(-100,0,-110,0)
	lg.circle("line",self.x,self.y, self.r + self.lineWidth + self.padding)

	lg.setLineWidth(originalWidth)
end

function RadialControl:drawArc(x, y, r, angle1, angle2, segments)
	local i = angle1
	local j = 0
	local k = 0
	local step = math.pi * 2 / segments
	local originalWidth = lg.getLineWidth()
    lg.setLineWidth(self.lineWidth)

	while i < angle2 do
    	j = angle2 - i < step and angle2 or i + step
    	
    	lg.line(x + (math.sin(i) * r), y - (math.cos(i) * r), x + (math.sin(j) * r), y - (math.cos(j) * r))
    	i = j
    	k = k + 1
	end

	lg.setLineWidth(originalWidth)
end

function RadialControl:drawStop()
	lg.setColor(128,128,128)
	self:drawArc(self.x,self.y,self.r,math.rad(-90),math.rad(-80),self.numSegments)	
	self:drawArc(self.x,self.y,self.r,math.rad(260),math.rad(270),self.numSegments)
end

function RadialControl:drawNumber( ... )
	local fontHeight = RadialControl.FONT:getHeight(self.value)
	local fontWidth = RadialControl.FONT:getWidth(self.value)
	local originalFont = lg.getFont()

	lg.setColor(200,200,200)
	lg.setFont(RadialControl.FONT)
	lg.printf(self.value,self.x-fontWidth,self.y-fontHeight/2,fontWidth*2,"center")
	lg.setFont(originalFont)

	local lineWidth = 100
	local linePadding = 2.5
	local originalWidth = lg.getLineWidth()
	local topMargin = 8

	lg.setColor(128,128,128)

	lg.setLineWidth(1)
	lg.line(self.x+lineWidth/2,self.y+fontHeight/2+linePadding,self.x-lineWidth/2,self.y+fontHeight/2+linePadding )
	lg.line(self.x+lineWidth/2,self.y-fontHeight/2-linePadding-topMargin,self.x-lineWidth/2,self.y-fontHeight/2-linePadding-topMargin )
	lg.setLineWidth(originalWidth)
end

function RadialControl:drawUnderGhost()
	lg.setColor(200,200,200)
	if not self.mouseClicked and self.ghostAngle > self.arcTween.stopAngle then
		self:drawArc(self.x,self.y,self.r,self.arcTween.stopAngle,self.ghostAngle,self.numSegments)
	end
end

function RadialControl:drawGhost()
	if self.mouseClicked then
		lg.setColor(200,200,200)

		if self.ghostAngle < self.arcTween.stopAngle then
			self:drawArc(self.x,self.y,self.r,self.ghostAngle,self.arcTween.stopAngle,self.numSegments)
		else
			self:drawArc(self.x,self.y,self.r,self.arcTween.stopAngle,self.ghostAngle,self.numSegments)
		end
	end
end

function RadialControl:drawGhostNumber( ... )
	local fontHeight = RadialControl.FONT2:getHeight(self.value)
	local fontWidth = RadialControl.FONT2:getWidth(self.value)
	local originalFont = lg.getFont()

	lg.setColor(125,125,125)
	lg.setFont(RadialControl.FONT2)
	lg.printf(self.currentValue,self.x-fontWidth,self.y-fontHeight/2+65,fontWidth*2,"center")
	lg.setFont(originalFont)
end

function RadialControl:drawUnit()
	local fontHeight = RadialControl.FONT2:getHeight(self.value)
	local fontWidth = RadialControl.FONT2:getWidth(self.value)
	local originalFont = lg.getFont()

	lg.setColor(125,125,125)
	lg.setFont(RadialControl.FONT2)
	lg.printf("kW",self.x-fontWidth,self.y-fontHeight/2-70,fontWidth*2,"center")
	lg.setFont(originalFont)
end

function RadialControl:update()
	self:updateNumber()
	self:updateGhostNumber()
	self:updateArc()
end

function RadialControl:draw()
	self:drawCircle()
	self:drawUnderGhost()

	lg.setColor(self.arcTween.r,self.arcTween.g,self.arcTween.b)
	self:drawArc(self.x,self.y,self.r,self.arcTween.startAngle,self.arcTween.stopAngle,self.numSegments)
	
	self:drawNumber()
	self:drawStop()
	self:drawGhost()
	self:drawGhostNumber()
	self:drawUnit()
end

function RadialControl:mousepressed(x,y,button)
	if button == "l" then
		self.mouseClicked = true
	elseif button == "wu" then
		if self.currentValue >= 100 then else
--			self.mouseClicked = true -- this is kind of hack-y, whoops
			self.ghostAngle = self.ghostAngle + math.rad(2)
		end
	elseif button == "wd" then
		if self.currentValue <= 0 then else
			self.ghostAngle = self.ghostAngle - math.rad(2)
		end
	end
end

function RadialControl:mousereleased(x,y,button)
	if button == "l" then
		self.mouseClicked = false
	end
	self:setAngle()
end

function RadialControl:keypressed(key)
--[[
	if key == NaN then 

]]
end

return RadialControl
