function Initialise()

  shell.run("clear")
  print("Place items in the turtles inventory to filter to the chest above the turtle.")
  print("Leave at least 1-4 slots empty for maximum speed.")
  print("Press Return when ready.")
  read()
  
  shell.run("clear")

  sortSlot = {}
  local i = 0
  for slot = 1,16 do
    if turtle.getItemCount(slot) > 0 then
      i = i + 1
      sortSlot[i] = slot
    end
  end
  
  if #sortSlot == 0 then
    print("Warning: No filters given. Filtering everything.")
    while true do
      for slot = 1,16 do
        turtle.dropUp()
      end
      sleep(0)
    end
  end
  if #sortSlot == 16 then
    error("Needs at least one slot empty.")
  end
  
  print("Sorting!")
  
end

function isSortItem(slot)
  turtle.select(slot)
  for i = 1,#sortSlot do
    if turtle.compareTo(sortSlot[i]) then
      return true
    end
  end
  return false
end

function isSortSlot(slot)
  for i = 1,#sortSlot do
    if slot == sortSlot[i] then
      return true
    end
  end
  return false
end

function isEmpty(slot)
  return turtle.getItemCount(slot) == 0
end

function filterAllButOne(slot)
  turtle.select(slot)
  turtle.dropUp(turtle.getItemCount(slot) - 1)
end

function filterAll(slot)
  turtle.select(slot)
  turtle.dropUp()
end

function passOn(slot)
  turtle.select(slot)
  turtle.drop()
end

function SortScript()
  while true do
    for slot = 1,16 do
      if not isEmpty(slot) then
        if isSortSlot(slot) then
          filterAllButOne(slot)
        elseif isSortItem(slot) then
          filterAll(slot)
        else
          passOn(slot)
        end
      end
    end
  sleep(0)
  end
end

Initialise()
SortScript()