#****************************************************************************
#**
#**  File     :  /cdimage/units/UEB4301/UEB4301_script.lua
#**  Author(s):  John Comes, Greg Kohne
#**
#**  Summary  :  UEF Heavy Shield Generator Script
#**
#**  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local TShieldStructureUnit = import('/lua/terranunits.lua').TShieldStructureUnit
local AIUtils = import('/lua/ai/aiutilities.lua')



UEB4301 = Class(TShieldStructureUnit) {
    
    ShieldEffects = {
        '/effects/emitters/terran_shield_generator_t2_01_emit.bp',
        '/effects/emitters/terran_shield_generator_T3_02_emit.bp',
        ###'/effects/emitters/terran_shield_generator_t2_03_emit.bp',
    },
	
    RegenBuffThread = function(self)
		print('this')
		print(self.regenRate)
		print(self.working)
		print(self.regenTick)
		print(self.regenRadius)
        while not self:IsDead() do
            local units = AIUtils.GetOwnUnitsAroundPoint(self:GetAIBrain(), categories.ALLUNITS, self:GetPosition(), self.regenRadius)
			if(self.working) then
				for _, unit in units do
					unit:SetHealth(self, unit:GetHealth()+(self.regenRate*self.regenTick))
				end
			end
            WaitSeconds(self.regenTick)
        end
    end,
    
    OnStopBeingBuilt = function(self,builder,layer)
		print('this 2')
		self.working = true
		self.regenRate = self:GetBlueprint().Defense.Repair.RegenRatePerSecond
		self.regenTick = self:GetBlueprint().Defense.Repair.RegenTick
		self.regenRadius = self:GetBlueprint().Defense.Shield.ShieldSize / 2
        
		self:ForkThread(self.RegenBuffThread)
		
		TShieldStructureUnit.OnStopBeingBuilt(self,builder,layer)
        self.Rotator1 = CreateRotator(self, 'Spinner', 'y', nil, 10, 5, 10)
        self.Rotator2 = CreateRotator(self, 'B01', 'z', nil, -10, 5, -10)
        self.Trash:Add(self.Rotator1)
        self.Trash:Add(self.Rotator2)
		self.ShieldEffectsBag = {}
    end,

    OnShieldEnabled = function(self)
		self.working = true
        TShieldStructureUnit.OnShieldEnabled(self)
        if self.Rotator1 then
            self.Rotator1:SetTargetSpeed(10)
        end
        if self.Rotator2 then
            self.Rotator2:SetTargetSpeed(-10)
        end
        
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
        for k, v in self.ShieldEffects do
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 0, self:GetArmy(), v ) )
        end
    end,

    OnShieldDisabled = function(self)
		self.working = false
        TShieldStructureUnit.OnShieldDisabled(self)
        self.Rotator1:SetTargetSpeed(0)
        self.Rotator2:SetTargetSpeed(0)
        
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
    end,

}

TypeClass = UEB4301