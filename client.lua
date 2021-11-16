--[[ SEAT SHUFFLE ]]--
--[[ BY JAF ]]--

local actionkey=21 --Lshift (or whatever your sprint key is bound to)
local allowshuffle = false

local playerped=PlayerPedId()
local currentvehicle=GetVehiclePedIsIn(playerped, false)
local playerped=nil
local currentvehicle=nil


--getting vars
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		--constantly getting the current 
		playerped=PlayerPedId()
		--constantly get player vehicle
		currentvehicle=GetVehiclePedIsIn(playerped, false)
	end
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		if IsPedInAnyVehicle(playerped, false) and allowshuffle == false then
			--if they're trying to shuffle for whatever reason
			SetPedConfigFlag(playerped, 184, true)
			if GetIsTaskActive(playerped, 165) then
				--getting seat player is in 
				seat=0
				if GetPedInVehicleSeat(currentvehicle, -1) == playerped then
					seat=-1
				end
				--if the passenger doesn't shut the door, shut it manually
				--if GetVehicleDoorAngleRatio(currentvehicle,1) > 0.0 and seat == 0 then
					--SetVehicleDoorShut(currentvehicle,1,false)
				--end
				--move ped back into the seat right as the animation starts
				SetPedIntoVehicle(playerped, currentvehicle, seat)
			end
		elseif IsPedInAnyVehicle(playerped, false) and allowshuffle == true then
			SetPedConfigFlag(playerped, 184, false)
		end
	end
end)


RegisterNetEvent("SeatShuffle")
AddEventHandler("SeatShuffle", function()
	if IsPedInAnyVehicle(playerped, false) then
		--getting seat
		seat=0
		if GetPedInVehicleSeat(currentvehicle, -1) == playerped then
			seat=-1
		end
		--if they're a driver
		if GetPedInVehicleSeat(currentvehicle,-1) == playerped then
			TaskShuffleToNextVehicleSeat(playerped,currentvehicle)
		end
		--if they're a passenger
		--adding a block until they are actually in their new seat
		allowshuffle=true
		while GetPedInVehicleSeat(currentvehicle,seat) == playerped do
			Citizen.Wait(0)
		end
		allowshuffle=false
	else
		allowshuffle=false
		CancelEvent('SeatShuffle')
	end
end)


local elapsed=0
--thread to get duration of key press
Citizen.CreateThread(function()
  while true do
	Citizen.Wait(0)
	elapsed=0
	while IsControlPressed(0,actionkey) and GetIsTaskActive(playerped, 165) do
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
		threshhold=0.8
		--if they're in passenger seat then remove add 1 second to the threshold because of slight delay when moving from passenger side
		--if GetPedInVehicleSeat(currentvehicle, 0) == playerped then
			--threshhold=threshhold+0.55
		--end
		--if the animation is playing and the key is pressed down for long enough, cancel the animation
	   if GetIsTaskActive(playerped, 165) and elapsed < threshhold then
			allowshuffle=false
	   end
    end
    Citizen.Wait(0)
  end
end)

RegisterCommand("shuff", function(source, args, raw) --change command here
    TriggerEvent("SeatShuffle")
end, false) --False, allow everyone to run it