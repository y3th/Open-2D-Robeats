--- Slider.lua
-- A simple slider
-- @author Magical_Noob

local Gameplay = script.Parent.Parent;
local Config = require(game.ReplicatedStorage:WaitForChild("GameConfig"));
local Signal = require(Gameplay:WaitForChild("Signal"));

local Slider = {};
Slider.__index = Slider;

local ENUMS = {
	failed = 0;
	passed = 1;
}

--- constructor
-- @param track: number
-- @param speed: number
function Slider:new(track, speed, distance)
	return setmetatable(
		{
			Passed = Signal:new();
			
			hitBot = false;
			
			posX = track / 4;
			positionTop = -(1/speed)*(distance/1000); -- every 1 second the thing goes from top to bottom
			positionBot = 0;
			track = track;
			speed = speed;
		}
	, Slider);
end

--- GetPosition
-- @param origin: number
-- @return pos: number
function Slider:GetPosition(origin)
	return self.hitBot and self.positionTop or self.positionBot;
end

--- OnAwake
-- @param MakeSleeve: function
function Slider:OnAwake(MakeSleeve)
	local sleeveBot = MakeSleeve(
		self.trackPos,
		self.parent,
		{
			ImageColor3 = self.color;
		}
	);
	
	local sleeveTop = MakeSleeve(
		self.trackPos,
		self.parent,
		{
			ImageColor3 = self.color;
		}
	);
	
	local sleeveBg = Instance.new("Frame");
	sleeveBg.Size = UDim2.new(0.25, 0, self.positionTop - self.positionBot, 0);
	sleeveBg.AnchorPoint = Vector2.new(0, 0.5);
	sleeveBg.BackgroundColor3 = self.color;
	sleeveBg.BackgroundTransparency = 0.5;
	sleeveBg.ZIndex = 50;
	sleeveBg.BorderSizePixel = 0;
	sleeveBg.Parent = self.parent;
	
	--- insert sleeve data to the note
	self.SleeveBg = sleeveBg;
	self.SleeveBottom = sleeveBot;
	self.SleeveTop = sleeveTop;	
end

--- OnNoteReleased
-- @param origin: number 
-- @param size: number 
-- @param score: NoteConfig 
function Slider:OnNoteReleased(origin, size, score)	
	if (not score) then
		self.Score:Fire(0);
		return;
	end
	
	self.Score:Fire(score.pts_add);
	self.hitBot = false;
	self:Destroy();
end

--- OnNoteHeld
-- @param origin: number
-- @param size: number
-- @param score: NoteConfig
function Slider:OnNoteHeld(origin, size, score)
	if (self.hitBot) then
		self.Score:Fire(0);
		return;
	end
	
	if (not score) then
		self.Score:Fire(0);
		return;
	end
	
	self.Score:Fire(score.pts_add);
	self.hitBot = true;
end

--- OnNoteHeld
function Slider:Destroy()
	self.Passed:Fire(true);

	--- Sweep other objects
	self.Score = nil;

	self.Passed:Destroy();
	self.SleeveBottom:Destroy();
	self.SleeveTop:Destroy();
	self.SleeveBg:Destroy();
	
	--- Sweep all contents
	self.position = nil;
	self.track = nil;
	self.speed = nil;
	self.color = nil;
	self.parent = nil;
	self.trackPos = nil;
end

--- Update
-- @param dt: number
function Slider:Update(dt)
	local delta = (dt * self.speed);
	self.positionBot += delta;
	self.positionTop += delta;
	
	self.SleeveBg.Position = UDim2.new(self.posX, 0, (self.positionTop + self.positionBot)/2, 0);
	self.SleeveBottom.Position = UDim2.new(self.posX, 0, self.positionBot, 0);
	self.SleeveTop.Position = UDim2.new(self.posX, 0, self.positionTop, 0);
	
	if (self.positionTop > Config.NOTE_FAIL_RANGE) then
		self.Score:Fire(0);
		self:Destroy();
	end

	return;
end

--- Export
return Slider;
