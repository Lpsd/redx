-- Author: Lpsd (https://github.com/Lpsd/redx)
-- See the LICENSE file @ root directory

MTA_PLATFORM = triggerClientEvent and "SERVER" or "CLIENT"
SERVER = triggerServerEvent == nil
CLIENT = not SERVER
DEBUG = false
SCREEN_WIDTH, SCREEN_HEIGHT = 1, 1
