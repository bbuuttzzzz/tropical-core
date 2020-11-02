GM.tRollResults = {}
GM.iRollWeightTotal = 0

function GM:RegisterRollResult( iWeight, sRollText, fEffect )
    local tResult = {}
    tResult.iWeight = iWeight
    tResult.sRollText = sRollText
    tResult.fEffect = fEffect

    self.tRollResults[#self.tRollResults+1] = tResult
    self.iRollWeightTotal = self.iRollWeightTotal + iWeight
end

function GM:ClearRollResults()
    self.tRollResults = {}
    self.iRollWeightTotal = 0
end

function GM:RollTheDice( tPl )
    -- pick a random number x from 1-n
    local iRoll = math.random(1,self.iRollWeightTotal)

    -- find the xth roll
    local tResult
    local iCurrentWeight = 0
    for _,tRoll in ipairs(self.tRollResults) do
        iCurrentWeight = iCurrentWeight + tRoll.iWeight
        if iRoll <= iCurrentWeight then
            tResult = tRoll
            break
        end
    end

    -- describe the roll
    tPl:ChatPrint("You rolled a " .. iRoll .. ": " .. tResult.sRollText)

    -- perform that role's effect
    tResult.fEffect( tPl )
end

local NAP_DURATION = 10
GM:RegisterRollResult( 5, "*YAWN* you feel sleepy", function( tPl )
    tPl:GiveTStatus("knockdown", NAP_DURATION )
    tPl:GiveTStatus("stop", NAP_DURATION )
end)

tRandomUselessnessText = {
    "your eyelids feel green",
    "the dust under your fingernails turns red!",
    "You experience a momentary feeling of inescapable doom!",
    "Your brain hurts!",
    "Your ears itch.",
    "Your nose twitches suddenly!"
}
for k,sText in ipairs(tRandomUselessnessText) do
    GM:RegisterRollResult( 1, sText, function() return end)
end
