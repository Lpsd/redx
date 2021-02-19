-- Author: Lpsd (https://github.com/Lpsd/)
-- See the LICENSE file @ root directory

-- *******************************************************************
DxScrollBar = inherit(DxElement)
-- *******************************************************************

function DxScrollBar:constructor(orientation)
    self.type = DX_SCROLLBAR

    self.orientation = orientation
end

-- *******************************************************************