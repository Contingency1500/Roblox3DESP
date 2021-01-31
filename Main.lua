--[[
ORIGINAL AUTHOR

Yes#0007 - 579306070040641546
]]--

_G.PlayerLocation = game:GetService("Players");


local VEC3 = Vector3.new
local VEC2 = Vector2.new
local COL3 = Color3.new
local RGB = Color3.fromRGB
local CFNEW = CFrame.new
local INSTNEW = Instance.new
local TBLINS = table.insert
local Drawing_new = Drawing.new
local Ray_new = Ray.new

local LocalPlayer = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace:FindFirstChildOfClass("Camera")
CreateDrawing = function(ClassName)
	return function(Props)
		local Create = Drawing_new(ClassName)
		for i,v in pairs(Props) do
			Create[i] = v
		end
		return Create
	end
end;
	
local Drawings = {}
function IsPartVisible(Part1, Part2)
    local CheckPart = INSTNEW("Part")
	CheckPart.Parent = Workspace
	CheckPart.Name = "CheckVisWall"
    CheckPart.Anchored = true
    CheckPart.CanCollide = false
    CheckPart.Transparency = 1
    CheckPart.Size = VEC3(2.5, 2.5, 2.5)
    CheckPart.CFrame = Part2.CFrame
    
    local Ray = Ray_new(Part1.Position, (Part2.Position - Part1.Position).unit * 9999)
    local part,position = workspace:FindPartOnRay(Ray, Part1.Parent)
	if part then
	    if part.Name == CheckPart.Name then
	        CheckPart:Destroy()
	        return true
	    end
	end
	CheckPart:Destroy()
	return false
end

function GetLookVectorAndOrigin(PART)
	local Origin = PART.CFrame
	local LookVector = PART.CFrame.lookVector * 100
	--local Direction = (LookVector - Origin.p).Unit * 100
	
	--local Ray = Ray.new(Origin.p, Direction)
	--local _, EndPosition = workspace:FindPartOnRay(Ray)
	
	return {
		Origin = Origin;
		EndPoint = LookVector;--Workspace:Raycast(Origin, Direction.p).Position;
	}
end
function Get8Corners(PART, OFF)
	if not OFF then OFF = VEC3(1, 1, 1) end
	local CornerVertices = {
		{1, 1, -1},  --v1 - top front right
		{1, -1, -1}, --v2 - bottom front right
		{-1, -1, -1},--v3 - bottom front left
		{-1, 1, -1}, --v4 - top front left
		
		{1, 1, 1},  --v5 - top back right
		{1, -1, 1}, --v6 - bottom back right
		{-1, -1, 1},--v7 - bottom back left
		{-1, 1, 1}  --v8 - top back left
	}
	local Vertices = {}
	local Size = PART.Size * OFF
	for _, Vector in pairs(CornerVertices) do
	    TBLINS(Vertices, (PART.CFrame * CFNEW(Size .X/2 * Vector[1], Size .Y/2 * Vector[2], Size .Z/2 * Vector[3])).Position)
	end
	return Vertices
end

function tocam(pos)
    local PosChar, withinScreenBounds = Camera:WorldToViewportPoint(pos)
    return {VEC2(PosChar.X, PosChar.Y), withinScreenBounds}
end
function Cleanup()
	for i,v in pairs(Drawings) do
		v:Remove()
		--table.remove(Drawings, i)
	end
	Drawings = {}
end
function Create3DVertex(PART, SETT)
	local VertexPositions = Get8Corners(PART, SETT.Offset)
	for i,v in pairs(Get8Corners(PART, VEC3(0.01, 0.01, 0.01))) do
		if not tocam(v)[2] then return end
	end
	local Thickness = SETT.Thickness
	local Transparency = SETT.Transparency
	local Visible = SETT.Visible
	local Color = SETT.Color
	local Filled = SETT.Filled
	local Positions = {
		{
			tocam(VertexPositions[5])[1];
			tocam(VertexPositions[6])[1];
			tocam(VertexPositions[2])[1];
			tocam(VertexPositions[1])[1];
		};
		{
			tocam(VertexPositions[7])[1];
			tocam(VertexPositions[8])[1];
			tocam(VertexPositions[4])[1];
			tocam(VertexPositions[3])[1];
		};
		{
			tocam(VertexPositions[1])[1];
			tocam(VertexPositions[2])[1];
			tocam(VertexPositions[3])[1];
			tocam(VertexPositions[4])[1];
		};
		{
			tocam(VertexPositions[5])[1];
			tocam(VertexPositions[6])[1];
			tocam(VertexPositions[7])[1];
			tocam(VertexPositions[8])[1];
		};
	}
	
	for i = 1,#Positions do
		local NewVertex = CreateDrawing("Quad") {
			["Visible"] = Visible;
			["Transparency"] = Transparency;
			["Thickness"] = Thickness;
			["Color"] = Color;
			["Filled"] = Filled;
			["PointA"] = Positions[i][1];
			["PointB"] = Positions[i][2];
			["PointC"] = Positions[i][3];
			["PointD"] = Positions[i][4];
		}
		Drawings[#Drawings + 1] = NewVertex
	end
end

while true do
	Cleanup()
	
	local func, ok = pcall(function()
		for i,v in pairs(_G.PlayerLocation:GetChildren()) do
			if v.Name ~= LocalPlayer.Name then
				local Char = v.Character or nil
				if Char then
					local Root = Char.HumanoidRootPart or nil
					local Head = Char.Head or nil
					
					if Root and Head and tocam(Head.Position)[2] then
						--[[ Vertex ]]--
						Create3DVertex(Root, {
							["Offset"] = VEC3(2.25, 3, 3);
							["Thickness"] = 1;
							["Transparency"] = 1;
							["Filled"] = false;
							["Visible"] = true;
							["Color"] = COL3(1,1,1);
						}) 
						
						--[[ Health ]]--
						Create3DVertex(Root, {
							["Offset"] = VEC3(2.25, 3/100*Char.Humanoid.Health, 3);
							["Thickness"] = 1;
							["Transparency"] = 0.1;
							["Filled"] = true;
							["Visible"] = true;
							["Color"] = COL3(0,1,0);
						})
						
						--[[ Tracer ]]--
						local ToCam = tocam(Head.Position)
						if ToCam[2] then
							local Mag = (LocalPlayer.Character.Head.Position - Head.Position).Magnitude
							local NewLine = CreateDrawing("Line") {
								["Visible"] = true;
								["Transparency"] = 1;
								["Thickness"] = 1;
								["Color"] = RGB(255/Mag*255,255/255*Mag,0);
								["From"] = VEC2(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y * 0.80);
								["To"] = ToCam[1];
							}
							Drawings[#Drawings + 1] = NewLine
						end

						--[[ OverHead ]]--
						
						--[[ IsVisible ]]--
						local Color
						if IsPartVisible(LocalPlayer.Character.Head, Head) then
							Color = COL3(0,1,0);
						else
							Color = COL3(1,0,0);
						end
						local PosPart = INSTNEW("Part")
						PosPart.CFrame = Head.CFrame
						PosPart.Size = VEC3(1,1,1)
						PosPart.Transparency = 1
						Create3DVertex(PosPart, {
							["Offset"] = VEC3(1,1,1);
							["Thickness"] = 1;
							["Transparency"] = 1;
							["Filled"] = false;
							["Visible"] = true;
							["Color"] = Color;
						})
						PosPart:Destroy()
					end
				end
			end
		end
		return true
	end)
	if not func then warn(ok) end

	RunService.RenderStepped:Wait()
end
