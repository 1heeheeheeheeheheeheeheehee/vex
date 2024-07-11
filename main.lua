-- Configuration variables (adjust these as needed)
getgenv().OldAimPart = "UpperTorso"
getgenv().AimPart = "UpperTorso"  -- For R15 Games: {UpperTorso, LowerTorso, HumanoidRootPart, Head} | For R6 Games: {Head, Torso, HumanoidRootPart}
getgenv().AimlockKey = Enum.KeyCode.C
getgenv().AimRadius = 30  -- How far away from someone's character you want to lock on
getgenv().ThirdPerson = true
getgenv().FirstPerson = true
getgenv().TeamCheck = false  -- Check if Target is on your Team (True means it won't lock onto your teammates, false is vice versa) (Set it to false if there are no teams)
getgenv().PredictMovement = true  -- Predicts if they are moving in fast velocity (like jumping) so the aimbot will go a bit faster to match their speed
getgenv().PredictionVelocity = 6.612
getgenv().CheckIfJumped = true
getgenv().Smoothness = true
getgenv().SmoothnessAmount = 0.015

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Client = Players.LocalPlayer
local Mouse = Players.LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local CFrame_new = CFrame.new
local Ray_new = Ray.new
local Vector3_new = Vector3.new
local Vector2_new = Vector2.new

local Aimlock = true
local MousePressed = false
local CanNotify = false
local AimlockTarget = nil

getgenv().WorldToViewportPoint = function(P)
    return Camera:WorldToViewportPoint(P)
end

getgenv().WorldToScreenPoint = function(P)
    return Camera:WorldToScreenPoint(P)
end

getgenv().GetObscuringObjects = function(T)
    if T and T:FindFirstChild(getgenv().AimPart) and Client and Client.Character:FindFirstChild("Head") then
        local RayPos = workspace:FindPartOnRay(Ray_new(
            T[getgenv().AimPart].Position, Client.Character.Head.Position)
        )
        if RayPos then return RayPos:IsDescendantOf(T) end
    end
end

getgenv().GetNearestTarget = function()
    local players = {}
    local PLAYER_HOLD = {}
    local DISTANCES = {}

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Client then
            table.insert(players, v)
        end
    end

    for _, v in pairs(players) do
        if v.Character then
            local AIM = v.Character:FindFirstChild("Head")

            if getgenv().TeamCheck == true and v.Team ~= Client.Team then
                local DISTANCE = (v.Character.Head.Position - Camera.CFrame.p).magnitude
                local RAY = Ray_new(Camera.CFrame.p, (Mouse.Hit.p - Camera.CFrame.p).unit * DISTANCE)
                local HIT, POS = workspace:FindPartOnRay(RAY, workspace)
                local DIFF = math.floor((POS - AIM.Position).magnitude)

                PLAYER_HOLD[v.Name .. _] = {}
                PLAYER_HOLD[v.Name .. _].dist = DISTANCE
                PLAYER_HOLD[v.Name .. _].plr = v
                PLAYER_HOLD[v.Name .. _].diff = DIFF

                table.insert(DISTANCES, DIFF)
            elseif getgenv().TeamCheck == false and v.Team == Client.Team then
                local DISTANCE = (v.Character.Head.Position - Camera.CFrame.p).magnitude
                local RAY = Ray_new(Camera.CFrame.p, (Mouse.Hit.p - Camera.CFrame.p).unit * DISTANCE)
                local HIT, POS = workspace:FindPartOnRay(RAY, workspace)
                local DIFF = math.floor((POS - AIM.Position).magnitude)

                PLAYER_HOLD[v.Name .. _] = {}
                PLAYER_HOLD[v.Name .. _].dist = DISTANCE
                PLAYER_HOLD[v.Name .. _].plr = v
                PLAYER_HOLD[v.Name .. _].diff = DIFF

                table.insert(DISTANCES, DIFF)
            end
        end
    end

    if next(DISTANCES) == nil then
        return nil
    end

    local L_DISTANCE = math.floor(math.min(unpack(DISTANCES)))

    if L_DISTANCE > getgenv().AimRadius then
        return nil
    end

    for _, v in pairs(PLAYER_HOLD) do
        if v.diff == L_DISTANCE then
            return v.plr
        end
    end

    return nil
end

Mouse.KeyDown:Connect(function(input)
    if not UserInputService:GetFocusedTextBox() then
        if input.KeyCode == getgenv().AimlockKey and AimlockTarget == nil then
            pcall(function()
                if not MousePressed then
                    MousePressed = true
                end

                local Target = getgenv().GetNearestTarget()

                if Target then
                    AimlockTarget = Target
                end
            end)
        elseif input.KeyCode == getgenv().AimlockKey and AimlockTarget ~= nil then
            if AimlockTarget ~= nil then
                AimlockTarget = nil
            end

            if MousePressed then
                MousePressed = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if getgenv().ThirdPerson == true and getgenv().FirstPerson == true then
        if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude > 1 or (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1 then
            CanNotify = true
        else
            CanNotify = false
        end
    elseif getgenv().ThirdPerson == true and getgenv().FirstPerson == false then
        if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude > 1 then
            CanNotify = true
        else
            CanNotify = false
        end
    elseif getgenv().ThirdPerson == false and getgenv().FirstPerson == true then
        if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1 then
            CanNotify = true
        else
            CanNotify = false
        end
    end

    if Aimlock and MousePressed then
        if AimlockTarget and AimlockTarget.Character and AimlockTarget.Character:FindFirstChild(getgenv().AimPart) then
            if getgenv().FirstPerson == true then
                if CanNotify == true then
                    if getgenv().PredictMovement == true then
                        if getgenv().Smoothness == true then
                            local Main = CFrame_new(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position + AimlockTarget.Character[getgenv().AimPart].Velocity / getgenv().PredictionVelocity)
                            Camera.CFrame = Camera.CFrame:Lerp(Main, getgenv().SmoothnessAmount, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut)
                        else
                            Camera.CFrame = CFrame_new(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position + AimlockTarget.Character[getgenv().AimPart].Velocity / getgenv().PredictionVelocity)
                        end
                    elseif getgenv().PredictMovement == false then
                        if getgenv().Smoothness == true then
                            local Main = CFrame_new(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position)
                            Camera.CFrame = Camera.CFrame:Lerp(Main, getgenv().SmoothnessAmount, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut)
                        else
                            Camera.CFrame = CFrame_new(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position)
                        end
                    end
                end
            end
        end
    end

    if getgenv().CheckIfJumped == true then
        if AimlockTarget and AimlockTarget.Character and AimlockTarget.Character.Humanoid.FloorMaterial == Enum.Material.Air then
            getgenv().AimPart = "UpperTorso"
        else
            getgenv().AimPart = getgenv().OldAimPart
        end
    end
end)
