-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

MTA_PLATFORM = triggerClientEvent and "SERVER" or "CLIENT"
SERVER = triggerServerEvent == nil
CLIENT = not SERVER
DEBUG = false
SCREEN_WIDTH, SCREEN_HEIGHT = 1, 1

DX_TYPES = {}
DX_TYPES_CLASSES = {
    ["BASE"] = "Dx",
    ["RECT"] = "Rect"
}
