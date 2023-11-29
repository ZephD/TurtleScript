shell.run("clear")
print("'BoreMe!' v0.1\nBy Zeph\n")

-- Parameters
YAW = {FORWARD=0,RIGHT=1,BACK=2,LEFT=3}
cYaw = YAW.FORWARD
X = 0
Y = 0
Depth = 0
fuelSlot = 16

args = {...}
if #args==0 then
  print("How many shafts would you like to dig?")
  print("  Tip: 1, 9, 25, 49, 81... are nice numbers")
  maxNumShafts = tonumber(read()) or 9
else
  for i = 1,5 do
    sleep(0.5)
    write(".")
  end
  maxNumShafts = tonumber(args[1]) or 9
end
if maxNumShafts == 0 then
  maxNumShafts = 1
end

shell.run("clear")

-- Boring Functions (Boilerplate)
function MoveForward()
  CheckFuel()
  if not turtle.forward() then
    if turtle.detect() and CheckInventory() then
      turtle.select(fuelSlot)
      turtle.dig()
    elseif turtle.attack() then
      while turtle.attack() do sleep(1) end
    end
    sleep(0.5)
    -- Try Again
    if not turtle.forward() then
      return false
    end
  end
  UpdatePosition(1)
  return true
end

function MoveBack()
  CheckFuel()
  if not turtle.back() then
    TurnNRight(2)
    if not MoveForward() then
      return false
    end
    TurnNRight(2)
  end
  UpdatePosition(-1)
  return true
end

function MoveDown()
  CheckFuel()
  if not turtle.down() then
    if turtle.detectDown() and CheckInventory() then
      turtle.select(fuelSlot)
      turtle.digDown()
    elseif turtle.attackDown() then
      while turtle.attackDown() do sleep(1) end
    end
    sleep(0.5)
    -- Try Again
    if not turtle.down() then
      return false
    end
  end
  Depth = Depth - 1;
  return true
end

function MoveUp()
  CheckFuel()
  if not turtle.up() then
    if turtle.detectUp() and CheckInventory() then
      turtle.select(fuelSlot)
      turtle.digDown()
    elseif turtle.attackUp() then
      while turtle.attackUp() do sleep(1) end
    end
    sleep(0.5)
    -- Try Again
    if not turtle.up() then
      return false
    end
  end
  Depth = Depth + 1;
  return true
end

function TurnRight()
  if not turtle.turnRight() then
    sleep(0.5)
    if not turtle.turnRight() then
      return false
    end
  end
  UpdateDirection(1)
  return true
end

function TurnLeft()
  if not turtle.turnLeft() then
    sleep(0.5)
    if not turtle.turnLeft() then
      return false
    end
  end
  UpdateDirection(-1)
  return true
end

function MoveNForward(n)
  local i = 0
  local a = 0 -- attempts
  while i<n do
    a = a + 1
    if MoveForward() then
      i = i + 1
      a = 0
    else
      sleep(0.5)
    end
    if a > 5 then
      print("Warning: Unable to move forwards!")
      break
    end
  end
  return i
end

function TurnNRight(n)
  local i = 0
  local a = 0 -- attempts
  while i<n do
    a = a + 1
    if TurnRight() then
      i = i + 1
      a = 0
    else
      sleep(0.5)
    end
    if a > 5 then
      error("Warning: Unable to turn right!")
    end
  end 
end

function TurnNLeft(n)
  local i = 0
  local a = 0 -- attempts
  while i<n do
    a = a + 1
    if TurnLeft() then
      i = i + 1
      a = 0
    else
      sleep(0.5)
    end
    if a > 5 then
      error("Warning: Unable to turn left!")
    end
  end 
end

function FaceYaw(yaw)
  while cYaw ~= yaw do
    TurnRight()
  end
end

function UpdatePosition(d)
  if cYaw == YAW.FORWARD then
    Y = Y + d
  elseif cYaw == YAW.BACK then
    Y = Y - d
  elseif cYaw == YAW.RIGHT then
    X = X + d
  elseif cYaw == YAW.LEFT then
    X = X - d
  end
end

function UpdateDirection(yawDir)
  -- Turned right
  if yawDir == 1 then
    if cYaw == YAW.FORWARD then
      cYaw = YAW.RIGHT
    elseif cYaw == YAW.RIGHT then
      cYaw = YAW.BACK
    elseif cYaw == YAW.BACK then
      cYaw = YAW.LEFT
    elseif cYaw == YAW.LEFT then
      cYaw = YAW.FORWARD
    end
    
  -- Turned left
  elseif yawDir == -1 then
    if cYaw == YAW.FORWARD then
      cYaw = YAW.LEFT
    elseif cYaw == YAW.LEFT then
      cYaw = YAW.BACK
    elseif cYaw == YAW.BACK then
      cYaw = YAW.RIGHT
    elseif cYaw == YAW.RIGHT then
      cYaw = YAW.FORWARD
    end
  end
end

-- Fun Functions
function Initialise()
  -- Check for chest
  if not turtle.detectUp() then
    error("Place a chest above the Turtle")
  end
  -- Check for ignoreBlocks
  ignoreBlocks = {}
  local i = 0
  for slot = 1,16 do
    if slot ~= fuelSlot then
      if lastKnownEmpty == nil and turtle.getItemCount(slot) == 0 then
        lastKnownEmpty = slot
      end
      if turtle.getItemCount(slot) > 0 then
        i = i + 1
        ignoreBlocks[i] = slot
      end
    end
  end
  if lastKnownEmpty == nil then
    error("Turtle is full!")
  end
  if #ignoreBlocks == 0 then
    print("Warning! No ignore blocks detected. Is this correct?")
    local response = read()
    if response ~= "n" response ~= "N" or responce ~= "no" or responce ~= "No" or responce ~= "NO" then
      error("Ok, try again then!")
    end
  else
    print("NumIgnoreBlocks = "..#ignoreBlocks)
  end
end

function CheckInventory()
  if not HaveSpace() then
    GoToXYD(0,0,0)
    DepositAndRefuel()
    GoToXYD(rX,rY,rDepth)
    FaceYaw(rYaw)
  end
  return true
end

function HaveSpace()
  -- For speed, check lastKnownEmpty slot
  if turtle.getItemCount(lastKnownEmpty) == 0 then
    return true
  end
  -- Else check all slots
  for slot = 1,16 do
    if turtle.getItemCount(slot) == 0 then
      lastKnownEmpty = slot
      return true
    end
  end
  -- No? make space!
  return MakeSpace()
end

function MakeSpace()
  local haveMadeSpace = false
  for slot = 1,16 do
    turtle.select(slot)
    for i = 1,#ignoreBlocks do
      if slot == ignoreBlocks[i] then
        if turtle.getItemCount(ignoreBlocks[i]) > 1 then
          -- Is it an ignore block? Yes? Drop all but one
          turtle.dropDown(turtle.getItemCount(ignoreBlocks[i]) - 1)
        end
      else
        if turtle.compareTo(ignoreBlocks[i]) then
          -- Is it the same as an ignore block? Yes? bin it!
          turtle.dropDown()
          haveMadeSpace = true
        end
      end
    end
  end
  if not haveMadeSpace then
    print("Inventory Full!")
  end
  return haveMadeSpace
end

function DepositAndRefuel()
  if turtle.detectUp() then
    turtle.select(fuelSlot)
    turtle.suckUp()
    for slot = 1,16 do
      if slot ~= fuelSlot then
        local isIgnoreBlock = false
        for i = 1,#ignoreBlocks do
          if slot == ignoreBlocks[i] then
            isIgnoreBlock = true
          end
        end
        if not isIgnoreBlock then
          turtle.select(slot)
          turtle.dropUp()
        end
      end
    end
    print("Deposited Ores")
  else
    error("Cannot find chest!")
  end
end

function CheckFuel()
  local fuel = turtle.getFuelLevel()
  local fuelToGetHome = math.abs(X)+math.abs(Y)+math.abs(Depth)
  while fuel <= fuelToGetHome do
    turtle.select(fuelSlot)
    if not turtle.refuel(1) then
      -- Find other fuel
      for slot = 1,16 do
        turtle.select(slot)
        if turtle.refuel(1) then
          fuelSlot = slot
          break
        end
        -- If we have scanned them all
        if slot == 16 then
          print("Warning! Out of fuel! Attempting to get home...")
          GoToXYD(0,0,0)
        end
      end
    end
    fuel = turtle.getFuelLevel()
  end
end

function SaveState()
  rX = X
  rY = Y
  rDepth = Depth
  rYaw = cYaw
end

function Compare()
  if turtle.detect() then
    local isIgnoreBlock = false
    for i = 1,#ignoreBlocks do
      turtle.select(ignoreBlocks[i])
      if turtle.compare() then
        isIgnoreBlock = true
      end
    end
    if not isIgnoreBlock and CheckInventory() then
      turtle.select(fuelSlot)
      turtle.dig()
    end
  end
end

function CheckOres()
  for i = 1,4 do
    Compare()
    if i ~= 4 then
      TurnRight()
    end
  end
end

function GoToXYD(xx,yy,dd)
  -- Default to go "home"
  local xx = xx or 0
  local yy = yy or 0
  local dd = dd or 0
  -- if i'm not home, then save current position
  if X~=0 or Y~=0 or Z~=0 then
    SaveState()
  end
  if Depth < dd then
    -- If i'm deep, come up first
    GoToDepth(dd)
    GoToXY(xx,yy)
  else
    GoToXY(xx,yy)
    GoToDepth(dd)
  end
end

function GoToDepth(dd,checkOres)
  local dd = dd or 0
  local checkOres = checkOres or false
  local rYaw = cYaw -- Note: not global rYaw
  while Depth < dd do
    if checkOres then
      CheckOres()
    end
    MoveUp()
  end
  while Depth > dd do
    if checkOres then
      CheckOres()
    end
    MoveDown()
  end
  FaceYaw(rYaw)
end

function GoToXY(xx,yy)
  for i = 1,3 do -- three attempts
    dx = math.abs(X)
    dy = math.abs(Y)
    if dy>dx then
      if Y<yy then
        FaceYaw(YAW.FORWARD)
      elseif Y>yy then
        FaceYaw(YAW.BACK)
      end
      while Y~=yy do
        MoveForward()
      end
    else
      if X<xx then
        FaceYaw(YAW.RIGHT)
      elseif X>xx then
        FaceYaw(YAW.LEFT)
      end
      while X~=xx do
        MoveForward()
      end
    end 
  end
end

function Bore()
  while MoveDown() do end
end

function Spiral()
  local n = 2
  local nextSeq = math.floor(n^2 / 4)
  for shaftNum = 1,maxNumShafts do
    print("Bore: "..shaftNum.."/"..maxNumShaft)
    Bore()
    GoToDepth(0,true) -- checkOres = true
    MoveNForward(2)
    TurnLeft()
    MoveForward()
    if shaftNum ~= nextSeq then
      TurnRight()
    else
      n = n + 1
      nextSeq = math.floor(n^2 / 4)
    end
  end
end

-- Main Function
Initialise()
DepositAndRefuel()
Spiral()
GoToXYD(0,0,0)
DepositAndRefuel()