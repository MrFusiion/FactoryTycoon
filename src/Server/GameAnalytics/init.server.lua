while not _G.Loaded do task.wait() end

local GameAnalytics = _G.Server.GameAnalytics

local key
if game.PlaceId == 6096240015 then
	key = require(script.Publish)
else
	key = require(script.Dev)
end

GameAnalytics:initialize({
	build = "0.1",

	gameKey = key.gameKey,
	secretKey = key.secretKey,

	enableInfoLog = _G.Config.GA_INFO,
	enableVerboseLog = _G.Config.GA_VERBOSE,

	--debug is by default enabled in studio only
	enableDebugLog = false,

	automaticSendBusinessEvents = true,
	reportErrors = true,

	availableCustomDimensions01 = {},
	availableCustomDimensions02 = {},
	availableCustomDimensions03 = {},
	availableResourceCurrencies = {},
	availableResourceItemTypes = {},
	availableGamepasses = {}
})

game.Players.PlayerAdded:Connect(function(player)
	GameAnalytics:addDesignEvent(player.UserId, {
		eventId = "joined"
	})
end)

_G.Remotes:onEvent("GA.Error", function(player: Player, error: string, stackTrace: string, scriptName: string)
	GameAnalytics:addErrorEvent(player.UserId, {
		severity = GameAnalytics.EGAErrorSeverity.critical,
		message = ("[%s]: %s\n%s"):format(scriptName, error, stackTrace)
	})
end)