![REDX Logo](https://camo.githubusercontent.com/0564c55b9a39abe73bcaf8e37132e4836f8e82a71de365528693cfa2b2ba25c5/68747470733a2f2f692e696d6775722e636f6d2f314a61546f4a632e706e67)

### DX GUI Library for MTA:SA (Work In Progress)
reDX is a Graphical User Interface library for [Multi Theft Auto: San Andreas](https://mtasa.com/). It is class based (OOP), however you have the choice to use procedural style in your code.

It also features a powerful property listener and event system, allowing you to do some really creative stuff, without much effort or code.

The project is currently in early stages, so expected features may be missing. You can always request a feature by [submitting an issue](https://github.com/Lpsd/redx/issues/new).

### Releases
> There are no stable releases yet, check back later!

### Example code
```lua
window = DxWindow:new(500, 300, 400, 400, false, nil, "Test Window")
window:setDraggable(true)
window:setDraggableChildren(true)

item = DxRect:new(25, 25, 100, 100, false, window)
item:setDraggableChildren(true)

item2 = DxRect:new(75, 75, 50, 50, false, item)
item2:setDraggableChildren(true)
item2.style:setColor("background", 66, 66, 66)

item3 = DxRect:new(50, 50, 50, 50, false, item2)
item3.style:setColor("background", 99, 99, 99)
```

See the [wiki](https://github.com/Lpsd/redx/wiki/) for more details.
