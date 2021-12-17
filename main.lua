local RunService = game:GetService("RunService")
local function getService(serviceName)
    local service = game:GetService(serviceName)
    if service then
        return service
    else
        error("Service '" .. serviceName .. "' does not exist.")
    end
end

local Library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()

local Window = Library:CreateWindow({Name = "Hizon's Modpack | v3rm: DarkDn"})
local localPlayer = getService("Players").LocalPlayer

if getService("ReplicatedStorage"):FindFirstChild("JesterRuse") then
    local section = Window:CreateTab({Name = "Rogue Copy"})
    local LocalPlayerSection = section:CreateSection({Name = "LocalPlayer"}) do
        local settings = {}
        local FallDamageToggle = LocalPlayerSection:AddToggle({Name = "Disable Fall Damage", Default = false, Callback = function(value)
            localPlayer.Character.FallDamage.RemoteEvent.Script.Disabled = not value
            local fakevalue = workspace.AliveData[localPlayer.Name].Status:FindFirstChild("Carry")
            if fakevalue and not value then
                fakevalue:Destroy()
            end
            if value then
                local fakevalue = Instance.new("BoolValue")
                fakevalue.Name = "Carry"
                fakevalue.Parent = workspace.AliveData[localPlayer.Name].Status
            end
        end})
        local OldDays = localPlayer.Data.Days.Value
        local ForceDay1 = LocalPlayerSection:AddToggle({Name = "Force Day 1", Default = false, Callback = function(value)
            localPlayer.Data.Days.Value = value and math.max(1, localPlayer.Data.Days) or OldDays
        end})
        LocalPlayerSection:AddToggle({Name = "Auto Pickup Trinkets", Default = false, Callback = function(value)
            settings.AutoPickup = value
        end})
        local NoRagdoll = LocalPlayerSection:AddToggle({Name = "No Ragdoll", Default = false, Callback = function(value)
            settings.NoRagdoll = value
        end})
        local NoBurn = LocalPlayerSection:AddToggle({Name = "No Burn", Default = false, Callback = function(value)
            settings.NoBurn = value
        end})
        local NoStun = LocalPlayerSection:AddToggle({Name = "No Stun", Default = false, Callback = function(value)
            settings.NoStun = value
        end})
        local DieButton = LocalPlayerSection:AddButton({Name = "Die", Callback = function()
            firetouchinterest(workspace.Map.KillBricks:GetChildren()[3], localPlayer.Character.Torso, 0)
            firetouchinterest(workspace.Map.KillBricks:GetChildren()[3], localPlayer.Character.Torso, 1)
        end})
        local InfMana = LocalPlayerSection:AddToggle({Name = "Infinite Mana", Default = false, Callback = function(value)
            settings.InfMana = value
        end})
        local NoTurretDmg = LocalPlayerSection:AddButton({Name = "No Turret Damage", Callback = function(value)
            if localPlayer.Character.HumanoidRootPart:FindFirstChild("High") then
                localPlayer.Character.HumanoidRootPart.High:Destroy()
            end
        end})
        local InstaRe = LocalPlayerSection:AddButton({Name = "Instant Respawn", Callback = function(value)
            game.ReplicatedStorage.Loaded:FireServer()
        end})
        local InstaRe = LocalPlayerSection:AddButton({Name = "Refresh", Callback = function(value)
            local oldcf = localPlayer.Character.HumanoidRootPart.CFrame
            game.ReplicatedStorage.Loaded:FireServer()
            local Char = localPlayer.CharacterAdded:Wait()
            task.wait(.5)
            localPlayer.Character.HumanoidRootPart.CFrame = oldcf
        end})
        local NoCaptcha = LocalPlayerSection:AddToggle({Name = "Captcha Solver", Default = false, Callback = function(value)
            settings.AutoCaptcha = value
        end})
        local WalkSpeed = LocalPlayerSection:AddSlider({Name = "Walk Increment", Default = 0, Min = 0, Max = 50, Callback = function(value)
            settings.WalkSpeed = value
        end})

        local function CharacterAdded(Character)
            task.spawn(function()
                while Character.Parent and task.wait() do
                    if settings.InfMana then
                        Character.Stats.Mana.Value = 70
                    end
                    if settings.WalkSpeed and settings.WalkSpeed > 0 then
                        Character.HumanoidRootPart.CFrame += Character.Humanoid.MoveDirection*settings.WalkSpeed*.1
                    end
                end
            end)
            localPlayer.PlayerGui.ChildAdded:Connect(function(child)
                if child.Name == "Captcha" then
                    local Frame = child:FindFirstChildOfClass("Frame")
                    local Monster = Frame.Viewport:FindFirstChildOfClass("Model")
                    if not Monster then
                        repeat task.wait() Monster = Frame:FindFirstChildOfClass("Model") until Monster
                    end
                    local Options = Frame.Options
                    for i,v in pairs(Options:GetChildren()) do
                        if v.Name == Monster.Name then
                            for i,v in pairs(getconnections(v.MouseButton1Down)) do
                                task.delay(.1, function()
                                    v:Fire()
                                end)
                            end
                        end
                    end
                end
            end)
            Character.ChildAdded:Connect(function(child)
                if child.Name == "Ragdoll" and settings.NoRagdoll then
                    task.wait(.1)
                    child:Destroy()
                elseif child.Name == "Burn" and settings.NoBurn then
                    task.wait(.1)
                    child:Destroy()
                elseif child.Name == "Stun" and settings.NoBurn then
                    task.wait(.1)
                    child:Destroy()

                end
            end)
        end

        localPlayer.CharacterAdded:Connect(CharacterAdded)
        if localPlayer.Character then
            CharacterAdded(localPlayer.Character)
        end
        local trinkets = {}
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Render").OnClientEvent:Connect(function(Type, State, GUID, TrinketType, Location)
            if Type == "Trinket" and TrinketType ~= "Nothing" then
                --if State == "Render" then
                    trinkets[GUID] = {
                        Type = TrinketType,
                        Location = Location,
                    }
                --end
            end
        end)
        while task.wait(.1) do
            if settings.AutoPickup then
                for i,v in pairs(trinkets) do
                    if (v.Location.Position-localPlayer.Character.HumanoidRootPart.Position).Magnitude < 150 then
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestPickup"):FireServer("Trinket", i)
                        trinkets[i] = nil
                    end
                end
            end
        end
    end;
end
