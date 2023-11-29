shell.run("clear")
print("'GetMeDiamonds!' v0.1\nBy Zeph\n")
print("Assumes FlatBedrock (like with FTB)")
print("Setup:")
print("  16:Fuel(EG Coal),[15:EnderChest]")
print("  IgnoreBlocks:[1:(EG Stone)")
print("                2:(EG Dirt), 3:etc]\n")

arg = {...}

-- Parameters
YAW = {FORWARD=0,RIGHT=1,BACK=2,LEFT=3}
cYaw = YAW.FORWARD
X = 0
Y = 0
Depth = 0
maxRadius = tonumber(arg[1]) or 1 -- Default to 7
numLevels = 5 -- Covers all diamond layers
checkInvAndOre = true

-- Functions
function Initialise()
  for i = 1,5 do
    sleep(1)
    write(".")
  end
  shell.run("clear")
  print("\nHello, Master! I am Turtle!")
  ScanInventory()
  PreChecks()
  turtle.select(1)
  print("Turtle ready!")
  sleep(1)
end

function ScanInventory()
  for slot = 1,16 do
    -- Find firstEmptySlot
    if firstEmptySlot == nil and turtle.getItemCount(slot) == 0 then
      firstEmptySlot = slot
      lastKnownEmptySlot = slot
    end
    -- Find lastEmptySlot
    if firstEmptySlot ~=nil and turtle.getItemCount(slot) == 0 then
      lastEmptySlot = slot
    end
  end
  -- DEBUG: Remove
  print("FE: "..firstEmptySlot)
  print("LE: "..lastEmptySlot)
end

function PreChecks()
 if firstEmptySlot == nil or lastEmptySlot == nil then
    print("Turtle full! *burp*")
    error()
  end
  if lastEmptySlot == 14 then -- therefore 15 is chest
    print("Turtle has power of Ender!")
    enderChestMode = true
  else
    enderChestMode = false
    FindChest()
  end
  if lastEmptySlot == 16 then -- no Fuel!
    print("Master no feed Turtle. Turtle feed Turtle!")
    GetFuelAndDeposit()
    -- Rescan for updated lastEmptySlot
    ScanInventory()
    PreChecks()
  end
end

function FindChest()
  chestYaw = nil
  for i = 1,4 do
    if not turtle.detect() then
      TurnRight()
    else
      chestYaw = cYaw
      break
    end
  end
  if chestYaw == nil then
    print("Turtle cannot find Chest! Place Chest next to Turtle.")
    error()
  end
end

function CheckFuel(extra)
  local extra = extra or 0
  local cFuel = turtle.getFuelLevel()
  -- Always see if you can get home after perform the task.
  local costToGetHome = math.abs(X)+math.abs(Y)+math.abs(Depth)+extra
  while cFuel <= costToGetHome do
    turtle.select(16)
    turtle.refuel(1)
    cFuel = turtle.getFuelLevel()
    turtle.select(1)
    -- Check for low fuel
    if turtle.getItemCount(16) <= 1 then
      print("Turtle hungry! Turtle find food...")
      GetFuelAndDeposit()
    end
  end
  return true
end

function GetFuelAndDeposit()
  SaveStats()
  checkInvAndOre = false
  if enderChestMode then
    -- Clear Space
    MoveForward()
    MoveBack()
    -- Place EnderChest
    turtle.select(15)
    turtle.place()
    EmptyInventory()
    Refuel()
    -- Pick Up Chest
    turtle.select(15)
    turtle.dig()
    turtle.select(1)
    CheckFuel()
  else
    SaveStats()
    ReturnToOrigin()
    ReturnToSurface()
    FaceYaw(chestYaw)
    EmptyInventory()
    Refuel()
    if CheckFuel(math.abs(rDepth)+math.abs(rX)+math.abs(rY)) then
      ReturnToLayer()
      ReturnToPosition()
    else
      print("Turtle hungry! Turtle on strike!")
      error()
    end
  end
  checkInvAndOre = rCheckInvAndOre
end

function CheckInventory()
  -- For speed, first check lastKnownEmptySlot
  if turtle.getItemCount(lastKnownEmptySlot) == 0 then
    turtle.select(1)
    return true
  end
  -- Otherwise, check everything
  for slot = firstEmptySlot,lastEmptySlot do
    -- First, drop it if a IgnoreBlock (EG Dirt)
    turtle.select(slot)
    for ignoreBlock = 1,firstEmptySlot-1 do
      if turtle.compareTo(ignoreBlock) then
        turtle.drop()
      end
    end
    -- Then see if empty
    if turtle.getItemCount(slot) == 0 then
      lastKnownEmptySlot = slot
      turtle.select(1)
      return true
    end
  end
  print("Turtle full! *Burp*")
  turtle.select(1)
  return false
end

function EmptyInventory()
  local before = turtle.getItemCount(firstEmptySlot)
  -- Empty additional Ignore Blocks
  for slot = 1,firstEmptySlot-1 do
    -- Drop all but one
    turtle.drop(turtle.getItemCount(slot)-1)
  end
  -- Empty Inventory
  if turtle.detect() then
    for slot = firstEmptySlot,lastEmptySlot do
      turtle.select(slot)
      turtle.drop()
    end
  else
    print("Turtle no find chest!")
    Panic()
  end
  local after = turtle.getItemCount(firstEmptySlot)
  if before > after then
    print("Turtle has gift for Master. Turtle is good Turtle.")
  end
  turtle.select(1)
end

function Refuel()
  -- Should already be facing chest...
  if turtle.detect() then
    turtle.select(16)
    local before = turtle.getItemCount(16)
    turtle.suck()
    local after = turtle.getItemCount(16)
    if before >= after then
      print("Turtle no find food!")
    end
    -- if fuel STILL low...
    if after < 1 then
      print("Turtle starving!")
      Panic()
    end
  else
    -- This should not happen.. "should"...
    print("Turtle no find Chest!")
    Panic()
  end
  turtle.select(1)
end

function Panic()
  checkInvAndOre = false
  turtle.select(16)
  local cFuel = turtle.getFuelLevel()
  -- Eat as much as you need
  local costToGetHome = math.abs(X)+math.abs(Y)+math.abs(Depth)
  while cFuel <= costToGetHome do
    if turtle.getItemCount(16) == 0 then
      -- Eat the everything!
      shell.run("refuel", "all")
      break
    else
      turtle.refuel(1)
      cFuel = turtle.getFuelLevel()
    end
  end
  -- Try to get home!
  ReturnToOrigin()
  ReturnToSurface()
  print("Turtle paniced... Turtle sorry.")
  error()
end

function SaveStats()
  rX = X
  rY = Y
  rDepth = Depth
  rYaw = cYaw
  rCheckInvAndOre = checkInvAndOre
end

function FindOre()
  local dontDigUp = false
  local dontDigDown = false
  if turtle.detectUp() then
    for ignoreBlock = 1,firstEmptySlot-1 do
      if turtle.compareUp(ignoreBlock) then
        dontDigUp = true
      end
    end
  end
  if turtle.detectDown() then
    for ignoreBlock = 1,firstEmptySlot-1 do
      if turtle.compareDown(ignoreBlock) then
        dontDigDown = true
      end
    end
  end
  if not dontDigUp then
    if CheckInventory() then
      turtle.digUp()
    else
      GetFuelAndDeposit()
    end
  end
  if not dontDigDown then
    if CheckInventory() then
      turtle.digDown()
    else
      GetFuelAndDeposit()
    end
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
  -- Turn right
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
    
  -- Turn left
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

function MoveUp(dist)
  local dist = dist or 1
  for i=1,dist do
    if turtle.up() then
      Depth = Depth + 1
    else
      -- Clear Path
      if turtle.detectUp() then
        if checkInvAndOre then
          if CheckInventory() then
            turtle.digUp()
          else
            GetFuelAndDeposit()
          end
        else
          turtle.digUp()
        end
      elseif turtle.attackUp() then
        while turtle.attackUp() do end
      elseif turtle.getFuelLevel() == 0 then
        CheckFuel()
      end
      -- Try again
      if turtle.up() then
        Depth = Depth + 1
      else
        -- Failed to move dist (Bedrock?)
        return false
      end
    end
  end
  return true
end
  
function MoveDown(dist)
  local dist = dist or 1
  for i=1,dist do
    if turtle.down() then
      Depth = Depth - 1
    else
      -- Clear Path
      if turtle.detectDown() then
        if checkInvAndOre then
          if CheckInventory() then
            turtle.digDown()
          else
            GetFuelAndDeposit()
          end
        else
          turtle.digDown()
        end
      elseif turtle.attackDown() then
        while turtle.attackDown() do end
      elseif turtle.getFuelLevel() == 0 then
        CheckFuel()
      end
      -- Try again
      if turtle.down() then
        Depth = Depth - 1
      else
        -- Failed to move dist (Bedrock?)
        return i-1
      end
    end
  end
  return true
end

function MoveForward(dist)
  local dist = dist or 1
  for i=1,dist do
    if turtle.forward() then
      UpdatePosition(1)
    else
      -- Clear Path
      if turtle.detect() then
        if checkInvAndOre then
          if CheckInventory() then
            turtle.dig()
          else
            GetFuelAndDeposit()
          end
        else
          turtle.dig()
        end
      elseif turtle.attack() then
        while turtle.attack() do end
      elseif turtle.getFuelLevel() == 0 then
        CheckFuel()
      end
      -- Try again
      if turtle.forward() then
        UpdatePosition(1)
      else
        -- Failed to move dist (Bedrock?)
        return i-1
      end
    end
    if checkInvAndOre then
      FindOre()
    end
  end
  return true
end

function ForceMoveForwards(dist)
  local dist = dist or 1
  local r = 0
  while r~=true do
    r = MoveForward(dist - r)
    sleep(0.5)
  end
end

function MoveBack(dist)
  local dist = dist or 1
  for i=1,dist do
    if turtle.back() then
      UpdatePosition(-1)
    else
      -- Try forwards
      TurnRight(2)
      if not MoveForward() then
        return i-1
      end
      TurnRight(2)
    end
  end
  return true
end

function TurnRight()
  isSuccessful = turtle.turnRight()
  if isSuccessful then
    UpdateDirection(1)
  end
  return isSuccessful
end

function TurnLeft()
  isSuccessful = turtle.turnLeft()
  if isSuccessful then
    UpdateDirection(-1)
  end
  return isSuccessful
end

function FaceYaw(yaw)
  while cYaw ~= yaw do
    TurnRight()
  end
end

function FindBedrock()
  print("Goodbye, Master! Tally-ho!")
  local notAtBedrock = true
  while notAtBedrock==true do
    CheckFuel(1)
    notAtBedrock = MoveDown()
  end
end

function ReturnToOrigin()
  local attempts = 0
  while attempts <= 3 do
    attempts = attempts + 1
    dx = math.abs(X)
    dy = math.abs(Y)
    if dy>dx then
      if Y<0 then
        FaceYaw(YAW.FORWARD)
      elseif Y>0 then
        FaceYaw(YAW.BACK)
      end
      while Y~=0 do
        MoveForward()
      end
    else
      if X<0 then
        FaceYaw(YAW.RIGHT)
      elseif X>0 then
        FaceYaw(YAW.LEFT)
      end
      while X~=0 do
        MoveForward()
      end
    end
  end    
end

function ReturnToPosition()
  local attempts = 0
  while attempts <= 3 do
    attempts = attempts + 1
    dx = math.abs(X)
    dy = math.abs(Y)
    if dy>dx then
      if rY<Y then
        FaceYaw(YAW.BACK)
      elseif rY>Y then
        FaceYaw(YAW.FORWARDS)
      end
      while rY~=Y do
        MoveForward()
      end
    else
      if rX<X then
        FaceYaw(YAW.LEFT)
      elseif rX>X then
        FaceYaw(YAW.RIGHT)
      end
      while rX~=X do
        MoveForward()
      end
    end
  end   
  FaceYaw(rYaw)
end

function ReturnToSurface()
  while Depth<0 do
    MoveUp()
  end
  while Depth>0 do
    MoveDown()
  end
end

function ReturnToLayer()
  while Depth<rDepth do
    MoveUp()
  end
  while Depth>rDepth do
    MoveDown()
  end
end

function Spiral()
  -- Spiral out, checking fuel before each side
  for cRadius = 1,maxRadius do
    dist = 2*cRadius
    CheckFuel(1)
    FaceYaw(YAW.FORWARD)
    ForceMoveForwards(1)
    CheckFuel(dist-1)
    FaceYaw(YAW.RIGHT)
    ForceMoveForwards(dist-1)
    CheckFuel(dist)
    FaceYaw(YAW.BACK)
    ForceMoveForwards(dist)
    CheckFuel(dist)
    FaceYaw(YAW.LEFT)
    ForceMoveForwards(dist)
    CheckFuel(dist)
    FaceYaw(YAW.FORWARD)
    ForceMoveForwards(dist)
  end
end

function StripMine()
  for cLevel=1,numLevels do
    CheckFuel(1)
    MoveUp()
    if cLevel > 1 then
      CheckFuel(2)
      MoveUp(2)
    end
    if math.abs(Depth) > 1 then
      Spiral()
    else
      print("Turtle may break chest! Turtle skip this level.")
    end
    ReturnToOrigin()
  end
end

-- Main Function
Initialise()
FindBedrock()
StripMine() -- ends with ReturnToOrigin()
ReturnToSurface()
GetFuelAndDeposit()
print("Turtle did as Master bid! Turtle is good Turtle!")