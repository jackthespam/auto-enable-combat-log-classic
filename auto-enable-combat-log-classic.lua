AutoEnableCombatLog = (LibStub("AceAddon-3.0")):NewAddon("AutoEnableCombatLog", "AceConsole-3.0", "AceEvent-3.0");

AutoEnableCombatLog_Debug = true

function AutoEnableCombatLog:Debug(message)
    if AutoEnableCombatLog_Debug then
        AutoEnableCombatLog:Printf("|cff674ea7"..message.."|r");
    end
end

function AutoEnableCombatLog:Success(message)
    AutoEnableCombatLog:Printf("|cff00ff00"..message.."|r");
end

function AutoEnableCombatLog:Info(message)
    AutoEnableCombatLog:Print(message);
end

function AutoEnableCombatLog:Warn(message)
    AutoEnableCombatLog:Printf("|cffff5a00"..message.."|r");
end

function AutoEnableCombatLog:Error(message)
    AutoEnableCombatLog:Printf("|cffff0000"..message.."|r");
end

function AutoEnableCombatLog:CheckAdvancedCombatLog()
    -- https://wowpedia.fandom.com/wiki/Console_variables#List_of_Console_Variables
	local isAdvancedCombatLoggingEnabled = GetCVar("advancedCombatLogging") == "1";
	if isAdvancedCombatLoggingEnabled then
		AutoEnableCombatLog:Debug("Advanced Combat Logging is enabled. Combat log recording will automatically start upon entering a raid.");
	else
		AutoEnableCombatLog:Warn("Advanced Combat Logging is not enabled.");
		AutoEnableCombatLog:Warn("Trying to enable Advanced Combat Logging...");
		SetCVar("advancedCombatLogging", "1");
		AutoEnableCombatLog:Warn("Please, reload your UI and check the configuration at Main Menu > Options > Network > Advanced Combat Logging.");
	end
end

-- https://warcraft.wiki.gg/wiki/PLAYER_ENTERING_WORLD
function AutoEnableCombatLog:PLAYER_ENTERING_WORLD(eventName, ...)

	AutoEnableCombatLog:CheckAdvancedCombatLog();
	-- https://warcraft.wiki.gg/wiki/API_IsInInstance
	inInstance, instanceType = IsInInstance();
	-- https://warcraft.wiki.gg/wiki/API_LoggingCombat
	loggingCombat = LoggingCombat();

	-- entering a raid
	if inInstance and instanceType == "raid" then
        if not loggingCombat then
            AutoEnableCombatLog:Debug("Entering "..GetZoneText().." ["..GetSubZoneText().."]...");
            AutoEnableCombatLog:Debug("Enabling combat log...");
            LoggingCombat(true);
            if LoggingCombat() then
                AutoEnableCombatLog:Success("Combat log enabled.");
            else
                AutoEnableCombatLog:Error("Cannot enable combat log. Please, wait 10 seconds and activate it manually.");
            end
        else
            AutoEnableCombatLog:Debug("Combat log is already enabled.");
        end
	end

	-- exiting a raid
	if not inInstance and loggingCombat then
		LoggingCombat(false);
        AutoEnableCombatLog:Debug("Combat log disabled.");
	end
end;

function AutoEnableCombatLog:OnEnable()
	AutoEnableCombatLog:RegisterEvent("PLAYER_ENTERING_WORLD");
	AutoEnableCombatLog:CheckAdvancedCombatLog();
end
