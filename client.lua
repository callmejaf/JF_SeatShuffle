--[[ SEAT SHUFFLE ]]--
--[[ BY JAF ]]--

local actionkey=21 --Lshift (or whatever your sprint key is bound to)
local allowshuffle = false
local playerped=GetPlayerPed(-1)
local currentvehicle=GetVehiclePedIsIn(playerped, false)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		--constantly getting the current 
		playerped=GetPlayerPed(-1)
		--constantly get player vehicle
		currentvehicle=GetVehiclePedIsIn(playerped, false)
		--check if the player is in a vehicle
		if IsPedInAnyVehicle(playerped, false) and allowshuffle == false then
			--if they're a passenger
			if GetPedInVehicleSeat(currentvehicle, 0) == playerped  then
				--if they're trying to shuffle
				if GetIsTaskActive(playerped, 165) then
					--if the player doesn't shut the door, shut it manually
					if GetVehicleDoorAngleRatio(currentvehicle,1) > 0.0 then
						SetVehicleDoorShut(currentvehicle,1,false)
					end
					--move ped back into passenger seat right as the animation starts
					SetPedIntoVehicle(playerped, currentvehicle, 0)
				end
			end
		end
	end
end)


RegisterNetEvent("SeatShuffle")
AddEventHandler("SeatShuffle", function()
	if IsPedInAnyVehicle(playerped, false) then
		--if they're a driver
		if GetPedInVehicleSeat(currentvehicle,-1) == playerped then
			allowshuffle=true
			TaskShuffleToNextVehicleSeat(playerped,currentvehicle)
			--adding a block until they are actually in their new seat
			while GetPedInVehicleSeat(currentvehicle,-1) == playerped do
				Citizen.Wait(0)
			end
			allowshuffle=false
		--if they're a passenger
		elseif GetPedInVehicleSeat(currentvehicle,0) == playerped then
			allowshuffle=true
			--adding a block until they are actually in their new seat
			while GetPedInVehicleSeat(currentvehicle,0) == playerped do
				Citizen.Wait(0)
			end
			allowshuffle=false
		end
	else
		allowshuffle=false
		eventrunning=false
		CancelEvent('SeatShuffle')
	end
end)


local elapsed=0
--thread to get duration of key press
Citizen.CreateThread(function()
  while true do
	Citizen.Wait(0)
	elapsed=0
	while IsControlPressed(0,actionkey) do
		Citizen.Wait(100)
		elapsed=elapsed+0.1
	end
  end
end)



Citizen.CreateThread(function()
  while true do
  --if the press the control then start the animation
	if IsControlJustPressed(1, actionkey) then -- Lshift
	   TriggerEvent("SeatShuffle")
    end
	--if they release the control mid anim then set back
	if IsControlJustReleased(1, actionkey) and allowshuffle == true then 
		--setting threshold for how long the ksy should be pressed for
		threshhold=0.9
		--if they're in passenger seat then remove add 1 second to the threshold because of slight delay when moving from passenger side
		if GetPedInVehicleSeat(currentvehicle, 0) == playerped then
			threshhold=threshhold+0.55
		end
		--if the animation is playing and the key is pressed down for long enough, cancel the animation
	   if GetIsTaskActive(playerped, 165) and elapsed < threshhold then
			allowshuffle=false
			seat=0
			if GetPedInVehicleSeat(currentvehicle, -1) == playerped then
				seat=-1
			end
			SetPedIntoVehicle(playerped, currentvehicle, seat)
	   end
    end
    Citizen.Wait(0)
  end
end)

RegisterCommand("shuff", function(source, args, raw) --change command here
    TriggerEvent("SeatShuffle")
end, false) --False, allow everyone to run it