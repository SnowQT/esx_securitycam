local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX             			  = nil
local PlayerData			  = {}
local inMarker 				  = false
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local menuopen = false
local bankcamera = false
local policecamera = false
local blockbuttons = false

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(0)

        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj

            if ESX.IsPlayerLoaded() == true then
                PlayerData = ESX.GetPlayerData()
            end
        end)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

AddEventHandler('esx_securitycam:hasEnteredMarker', function (zone)
  if zone == 'Cameras' and not menuopen then
    CurrentAction     = 'cameras'
    CurrentActionMsg  = _U('marker_hint')
  end
  
end)

AddEventHandler('esx_securitycam:hasExitedMarker', function (zone)
  CurrentAction = nil
end)

Citizen.CreateThread(function()
  while true do

    Wait(0)

    local coords = GetEntityCoords(GetPlayerPed(-1))

    for k,v in pairs(Config.Zones) do
	if PlayerData.job ~= nil and PlayerData.job.name ~= 'unemployed' and PlayerData.job.name == "police" then
      if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
        DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
      end
	 end
    end

    local isInMarker  = false
    local currentZone = nil

    for k,v in pairs(Config.Zones) do
	if PlayerData.job ~= nil and PlayerData.job.name ~= 'unemployed' and PlayerData.job.name == "police" then
      if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < 2) then
        isInMarker  = true
        currentZone = k
      end
	 end
    end

    if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
      HasAlreadyEnteredMarker = true
      LastZone = currentZone
      TriggerEvent('esx_securitycam:hasEnteredMarker', currentZone)
    end

    if not isInMarker and HasAlreadyEnteredMarker then
      HasAlreadyEnteredMarker = false
      TriggerEvent('esx_securitycam:hasExitedMarker', LastZone)
      CurrentAction = nil
      ESX.UI.Menu.CloseAll()
    end
  end
end)

local cameraActive = false
local currentCameraIndex = 0
local currentCameraIndexIndex = 0
local createdCamera = 0
local screenEffect = "Seven_Eleven"

Citizen.CreateThread(function()
    while true do
        for a = 1, #Config.Locations do
			if IsControlJustReleased(0, Keys['E']) and CurrentAction == 'cameras' then

					if not menuopen then
						menuopen = true
						CurrentAction = nil
						local elements = {
						{label = _U('bank_menu_selection'), value = '1'},
						{label = _U('police_menu_selection'), value = '2'}
						}
  
						ESX.UI.Menu.CloseAll()

						ESX.UI.Menu.Open(
						'default', GetCurrentResourceName(), 'cloakroom',
						{
							title    = _U('securitycams_menu'),
							align    = 'top-left',
							elements = elements,
						},
						function(data, menu)
	
					if data.current.value == '1' then
						menu.close()
						bankcamera = true
						blockbuttons = true
						local pP = GetPlayerPed(-1)
						local firstCamx = Config.Locations[a].bankCameras[1].x
                        local firstCamy = Config.Locations[a].bankCameras[1].y
                        local firstCamz = Config.Locations[a].bankCameras[1].z
                        local firstCamr = Config.Locations[a].bankCameras[1].r
						SetFocusArea(firstCamx, firstCamy, firstCamz, firstCamx, firstCamy, firstCamz)
                        ChangeSecurityCamera(firstCamx, firstCamy, firstCamz, firstCamr)
                        SendNUIMessage({
                            type = "enablecam",
                            label = Config.Locations[a].bankCameras[1].label,
                            box = Config.Locations[a].bankCamLabel.label
                        })
					
                        currentCameraIndex = a
                        currentCameraIndexIndex = 1
						menuopen = false
						TriggerEvent('esx_securitycam:freeze', true)
					
						
					elseif data.current.value == '2' then
						menu.close()
						policecamera = true
						blockbuttons = true
						local pP = GetPlayerPed(-1)
						local firstCamx = Config.Locations[a].policeCameras[1].x
                        local firstCamy = Config.Locations[a].policeCameras[1].y
                        local firstCamz = Config.Locations[a].policeCameras[1].z
                        local firstCamr = Config.Locations[a].policeCameras[1].r
						SetFocusArea(firstCamx, firstCamy, firstCamz, firstCamx, firstCamy, firstCamz)
                        ChangeSecurityCamera(firstCamx, firstCamy, firstCamz, firstCamr)
                        SendNUIMessage({
                            type = "enablecam",
                            label = Config.Locations[a].policeCameras[1].label,
                            box = Config.Locations[a].policeCamLabel.label
                        })
					
                        currentCameraIndex = a
                        currentCameraIndexIndex = 1
						menuopen = false
						TriggerEvent('esx_securitycam:freeze', true)

end

    end,

    function(data, menu)
      menu.close()
      	local pP = GetPlayerPed(-1)
             menuopen = false
    end
)
                        
                    end
					end

            if createdCamera ~= 0 then
                local instructions = CreateInstuctionScaleform("instructional_buttons")
				
                DrawScaleformMovieFullscreen(instructions, 255, 255, 255, 255, 0)
                SetTimecycleModifier("scanline_cam_cheap")
                SetTimecycleModifierStrength(2.0)
				
                 if Config.HideRadar then
                    DisplayRadar(false)
					ESX.UI.HUD.SetDisplay(0.0)
					TriggerEvent('es:setMoneyDisplay', 0.0)
					TriggerEvent('esx_status:setDisplay', 0.0)
                end

                -- CLOSE CAMERAS
                if IsControlJustPressed(0, Keys["BACKSPACE"]) then
                    CloseSecurityCamera()
                    SendNUIMessage({
                        type = "disablecam",
                    })
					if Config.HideRadar then
						DisplayRadar(true)
						ESX.UI.HUD.SetDisplay(1.0)
						TriggerEvent('es:setMoneyDisplay', 1.0)
						TriggerEvent('esx_status:setDisplay', 1.0)
                    end
					CurrentAction = nil
					bankcamera = false
					policecamera = false
					blockbuttons = false
					TriggerEvent('esx_securitycam:freeze', false)
					
                end

                -- GO BACK CAMERA
                if IsControlJustPressed(0, Keys["LEFT"]) then
					if bankcamera then
						local newCamIndex

						if currentCameraIndexIndex == 1 then
							newCamIndex = #Config.Locations[currentCameraIndex].bankCameras
						else
							newCamIndex = currentCameraIndexIndex - 1
						end

						local newCamx = Config.Locations[currentCameraIndex].bankCameras[newCamIndex].x
						local newCamy = Config.Locations[currentCameraIndex].bankCameras[newCamIndex].y
						local newCamz = Config.Locations[currentCameraIndex].bankCameras[newCamIndex].z
						local newCamr = Config.Locations[currentCameraIndex].bankCameras[newCamIndex].r
						SetFocusArea(newCamx, newCamy, newCamz, newCamx, newCamy, newCamz)
						SendNUIMessage({
							type = "updatecam",
							label = Config.Locations[currentCameraIndex].bankCameras[newCamIndex].label
						})
						ChangeSecurityCamera(newCamx, newCamy, newCamz, newCamr)
						currentCameraIndexIndex = newCamIndex
					
					elseif policecamera then
						local newCamIndex

						if currentCameraIndexIndex == 1 then
							newCamIndex = #Config.Locations[currentCameraIndex].policeCameras
						else
							newCamIndex = currentCameraIndexIndex - 1
						end

						local newCamx = Config.Locations[currentCameraIndex].policeCameras[newCamIndex].x
						local newCamy = Config.Locations[currentCameraIndex].policeCameras[newCamIndex].y
						local newCamz = Config.Locations[currentCameraIndex].policeCameras[newCamIndex].z
						local newCamr = Config.Locations[currentCameraIndex].policeCameras[newCamIndex].r
						SetFocusArea(newCamx, newCamy, newCamz, newCamx, newCamy, newCamz)
						SendNUIMessage({
							type = "updatecam",
							label = Config.Locations[currentCameraIndex].policeCameras[newCamIndex].label
						})
						ChangeSecurityCamera(newCamx, newCamy, newCamz, newCamr)
						currentCameraIndexIndex = newCamIndex
					end
				end
				

                -- GO FORWARD CAMERA
                if IsControlJustPressed(0, Keys["RIGHT"]) then
					if bankcamera then
						local newCamIndex
                    
						if currentCameraIndexIndex == #Config.Locations[currentCameraIndex].bankCameras then
							newCamIndex = 1
						else
							newCamIndex = currentCameraIndexIndex + 1
						end

						local newCamx = Config.Locations[currentCameraIndex].bankCameras[newCamIndex].x
						local newCamy = Config.Locations[currentCameraIndex].bankCameras[newCamIndex].y
						local newCamz = Config.Locations[currentCameraIndex].bankCameras[newCamIndex].z
						local newCamr = Config.Locations[currentCameraIndex].bankCameras[newCamIndex].r
						SendNUIMessage({
							type = "updatecam",
							label = Config.Locations[currentCameraIndex].bankCameras[newCamIndex].label
						})
						ChangeSecurityCamera(newCamx, newCamy, newCamz, newCamr)
						currentCameraIndexIndex = newCamIndex
					elseif policecamera then
						local newCamIndex
                    
						if currentCameraIndexIndex == #Config.Locations[currentCameraIndex].policeCameras then
							newCamIndex = 1
						else
							newCamIndex = currentCameraIndexIndex + 1
						end

						local newCamx = Config.Locations[currentCameraIndex].policeCameras[newCamIndex].x
						local newCamy = Config.Locations[currentCameraIndex].policeCameras[newCamIndex].y
						local newCamz = Config.Locations[currentCameraIndex].policeCameras[newCamIndex].z
						local newCamr = Config.Locations[currentCameraIndex].policeCameras[newCamIndex].r
						SendNUIMessage({
							type = "updatecam",
							label = Config.Locations[currentCameraIndex].policeCameras[newCamIndex].label
						})
						ChangeSecurityCamera(newCamx, newCamy, newCamz, newCamr)
						currentCameraIndexIndex = newCamIndex
					end
				end
				
				if Config.Locations[currentCameraIndex].bankCameras[currentCameraIndexIndex].canRotate then
                    local getCameraRot = GetCamRot(createdCamera, 2)

                    -- ROTATE LEFT
                    if IsControlPressed(1, Keys['N4']) then
                        SetCamRot(createdCamera, getCameraRot.x, 0.0, getCameraRot.z + 0.7, 2)
                    end

                    -- ROTATE RIGHT
                    if IsControlPressed(1, Keys['N6']) then
                        SetCamRot(createdCamera, getCameraRot.x, 0.0, getCameraRot.z - 0.7, 2)
                    end
				
				elseif Config.Locations[currentCameraIndex].policeCameras[currentCameraIndexIndex].canRotate then
                    local getCameraRot = GetCamRot(createdCamera, 2)

                    -- ROTATE LEFT
                    if IsControlPressed(1, Keys['N4']) then
                        SetCamRot(createdCamera, getCameraRot.x, 0.0, getCameraRot.z + 0.7, 2)
                    end

                    -- ROTATE RIGHT
                    if IsControlPressed(1, Keys['N6']) then
                        SetCamRot(createdCamera, getCameraRot.x, 0.0, getCameraRot.z - 0.7, 2)
                    end
                end
            
			end
        Citizen.Wait(0)
    end
	end
end)

Citizen.CreateThread(function()
  while true do

    Wait(0)

    if CurrentAction ~= nil then
      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)
    end
  end
end)

function ChangeSecurityCamera(x, y, z, r)
    if createdCamera ~= 0 then
        DestroyCam(createdCamera, 0)
        createdCamera = 0
    end

    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    SetCamCoord(cam, x, y, z)
    SetCamRot(cam, r.x, r.y, r.z, 2)
    RenderScriptCams(1, 0, 0, 1, 1)
    Citizen.Wait(250)
    createdCamera = cam
end

function CloseSecurityCamera()
    DestroyCam(createdCamera, 0)
    RenderScriptCams(0, 0, 1, 1, 1)
    createdCamera = 0
	ClearTimecycleModifier("scanline_cam_cheap")
	SetFocusEntity(GetPlayerPed(PlayerId()))
end

function CreateInstuctionScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
	
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    InstructionButton(GetControlInstructionalButton(0, Keys["RIGHT"], true))
    InstructionButtonMessage("Next Camera")
	-- InstructionButtonMessage("Nästa Kamera") --SV LANGUAGE
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    InstructionButton(GetControlInstructionalButton(0, Keys["LEFT"], true))
    InstructionButtonMessage("Previous Camera")
	-- InstructionButtonMessage("Förra Kameran") --SV LANGUAGE
    PopScaleformMovieFunctionVoid()
	
	PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    InstructionButton(GetControlInstructionalButton(0, Keys["BACKSPACE"], true))
    InstructionButtonMessage("Close Cameras")
	-- InstructionButtonMessage("Stäng Kamerorna") --SV LANGUAGE
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

function InstructionButton(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function InstructionButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

RegisterNetEvent('esx_securitycam:freeze')
AddEventHandler('esx_securitycam:freeze', function(freeze)
	FreezeEntityPosition(GetPlayerPed(-1), freeze)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		if blockbuttons then
			DisableControlAction(2, 24, true)
			DisableControlAction(2, 257, true)
			DisableControlAction(2, 25, true)
			DisableControlAction(2, 263, true)
			DisableControlAction(2, Keys['R'], true)
			DisableControlAction(2, Keys['bottom-right'], true)
			DisableControlAction(2, Keys['SPACE'], true)
			DisableControlAction(2, Keys['Q'], true)
			DisableControlAction(2, Keys['TAB'], true)
			DisableControlAction(2, Keys['F'], true)
			DisableControlAction(2, Keys['F1'], true)
			DisableControlAction(2, Keys['F2'], true)
			DisableControlAction(2, Keys['F3'], true)
			DisableControlAction(2, Keys['F6'], true)
			DisableControlAction(2, Keys['F7'], true)
			DisableControlAction(2, Keys['F10'], true)
		else
			Citizen.Wait(1000)
		end
	end
end)
