print("'BranchMine!' v0.1")
print("16:Coal,15:EnderChest,14:Torch")
print("1+:Exclude (EG 1:Stone,2:Dirt)")

-- Parameters
arg = {...}
branchLength = tonumber(arg[1]) or 8
numBranch = branchLength
numExcludeBlocks = 0

-- Functions
function Initialise()
  if turtle.getItemCount(16) == 0 then
    error("No Fuel! (16)")
  end
--  if turtle.getItemCount(15) == 0 then
--    error("No EnderChest! (15)")
--  end
--  if turtle.getItemCount(14) == 0 then
--    error("No Torches! (14)")
--  end
  local i = 0
  for i = 1,13,1 do
    if turtle.getItemCount(i) > 0 then
      numExcludeBlocks = numExcludeBlocks + 1
    end
  end
  print("Found "..numExcludeBlocks.." excluded blocks!")
  turtle.select(1)
  print("Initialised!")
end

function CheckFuel(d)
  local d = d or 1
  local cFuel = turtle.getFuelLevel()
  while cFuel < d do
    turtle.select(16)
    turtle.refuel(1)
    cFuel = turtle.getFuelLevel()
    if turtle.getItemCount(16) < 1 then
      print("Out of fuel!")
      return false
    end
  end
  return true
end

function CheckBlock()
  local skip = false
  local i = 0
  for i = 1,numExcludeBlocks do
    if turtle.compare(i) then
      skip = true
    end
  end
  if not skip then
    turtle.dig()
  end
end

function CheckSides()
  TurnRight()
  CheckBlock()
  MoveUp()
  CheckBlock()
  TurnLeft(2)
  CheckBlock()
  MoveDown()
  CheckBlock()
  TurnRight()
  return true
end

function DigBranch()
  print("Digging Branch!")
  local cBranchStep = 0
  while cBranchStep < branchLength do
    print("Progress: "..cBranchStep.."/"..branchLength)
    if turtle.detect() then
      turtle.dig()
    end
    if turtle.detectUp() then
      turtle.digUp()
    end
    if CheckSides() then
      if not CheckFuel() then
        break
      end
      if MoveForward() then
        cBranchStep = cBranchStep + 1
      end
    end
  end
  print("Finished Branch! Returning!")
  TurnRight(2)
  CheckFuel(cBranchStep)
  MoveForward(cBranchStep)
  TurnRight(2)
  print("Returned!")
end

function TurnRight(times)
  local times = times or 1
  local i = 0
  for i = 1,times,1 do
    turtle.turnRight()
  end
end

function TurnLeft(times)
  local times = times or 1
  local i = 0
  for i = 1,times,1 do
    turtle.turnLeft()
  end
end

function MoveForward(dist)
  local dist = dist or 1
  local i = 0
  for i=1,dist do
    local isSuccessful = false
    while not isSuccessful do
      isSuccessful = turtle.forward()
      if not isSuccessful then
        if turtle.detect() then
          turtle.dig()
        else
          turtle.attack()
        end
      end
    end
  end
  return isSuccessful
end

function MoveUp(dist)
  local dist = dist or 1
  local i = 0
  for i=1,dist do
    local isSuccessful = false
    while not isSuccessful do
      isSuccessful = turtle.up()
      if not isSuccessful then
        if turtle.detectUp() then
          turtle.digUp()
        else
          turtle.attackUp()
        end
      end
    end
  end
  return isSuccessful
end

function MoveUp(dist)
  local dist = dist or 1
  local i = 0
  for i=1,dist do
    local isSuccessful = false
    while not isSuccessful do
      isSuccessful = turtle.down()
      if not isSuccessful then
        if turtle.detectDown() then
          turtle.digDown()
        else
          turtle.attackDown()
        end
      end
    end
  end
  return isSuccessful
end

-- Main Loop
Initialise()
DigBranch()
