
local path = mod_loader.mods[modApi.currentMod].resourcePath
local uiVisiblePawn = require(path .."scripts/replaceRepair/lib/uiVisiblePawn")
local icon = sdlext.surface("img/weapons/repair.png")
local iconFrozen = sdlext.surface("img/weapons/repair_frozen.png")
local iconSmoke = sdlext.surface(path .."scripts/replaceRepair/img/smoke.png")
local iconWater = sdlext.surface(path .."scripts/replaceRepair/img/water.png")
local iconAcid = sdlext.surface(path .."scripts/replaceRepair/img/acid.png")
local iconLava = sdlext.surface(path .."scripts/replaceRepair/img/lava.png")

local this = {}

function this.createui()
	sdlext.addUiRootCreatedHook(function(screen, uiRoot)
		local m = lmn_replaceRepair
		m.icon = Ui()
			:widthpx(32):heightpx(80)
			:decorate({ DecoSurface() })
			:addTo(uiRoot)
		
		m.icon.translucent = true
		m.icon.visible = false
		
		m.icon.clipRect1 = sdl.rect(0, 0, 32, 65)
		m.icon.clipRect2 = sdl.rect(0, 0, 18, 15)
		
		m.icon.draw = function(self, screen)
			self.visible = false
			
			local drawn
			local replacement = m.GetCurrentSkill()
			if not replacement then return end
			
			if icon:wasDrawn() then
				drawn = icon
				replacement = replacement.surface
			elseif iconFrozen:wasDrawn() then
				drawn = iconFrozen
				replacement = replacement.surface_frozen or replacement.surface
			end
			
			if drawn and replacement then
				self.x = drawn.x
				self.y = drawn.y
				
				self.clipRect1.x = self.x
				self.clipRect1.y = self.y
				self.clipRect2.x = self.x
				self.clipRect2.y = self.y + self.clipRect1.h
				
				if rect_intersects(self.clipRect1, sdlext.CurrentWindowRect) then
					self.clipRect1.w = math.max(0, math.min(32, sdlext.CurrentWindowRect.x - self.x))
					self.clipRect2.w = math.max(0, math.min(18, sdlext.CurrentWindowRect.x - self.x))
				else
					self.clipRect1.w = 32
					self.clipRect2.w = 18
				end
				
				self.visible = true
				self.decorations[1].surface = replacement
			end
			
			screen:clip(self.clipRect1)
			Ui.draw(self, screen)
			screen:unclip()
			screen:clip(self.clipRect2)
			Ui.draw(self, screen)
			screen:unclip()
		end
		
		-- Add water and smoke overlay images
		m.iconOverlay = Ui()
			:width(1):height(1)
			:decorate({ DecoSurface() })
			:addTo(m.icon)
		m.iconOverlay.translucent = true
		
		m.iconOverlay.draw = function(self, screen)
			self.visible = false
			
			if icon:wasDrawn() or iconFrozen:wasDrawn() then
				local pawn = uiVisiblePawn()
				local loc = pawn:GetSpace()
				local isFlying = pawn:IsFlying()
				
				if Board:IsTerrain(loc, TERRAIN_LAVA) and not isFlying then
					self.visible = true
					self.decorations[1].surface = iconLava
					
				elseif Board:GetTerrain(loc) == TERRAIN_WATER and not isFlying then
					self.visible = true
					self.decorations[1].surface = Board:IsAcid(loc) and iconAcid or iconWater
					
				elseif Board:IsSmoke(loc) and not pawn:IsAbility("Disable_Immunity") then
					self.visible = true
					self.decorations[1].surface = iconSmoke
				end
				
				Ui.draw(self, screen)
			end
		end
	end)
end

return this