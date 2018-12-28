--------------------------------------------------------------------------------------
--# Main
--------------------------------------------------------------------------------------
-- Glin V03.1.2
-- Stefan Haefeli, 02. Juli 2012
--------------------------------------------------------------------------------------

-- Anleitung

-- Zukuenftige Features
-------------------------------
-- Farbauswahl

-- Uhr ----------------------------------------------------
-- now=os.date("*t") --seems this gets passed to TextDisplay
-- thishour=now.hour
-- thismin=now.min
-- thissec=now.sec

-- Spezielle Glins:
-- - Bobme (3x3)
-- - Stern (zählt wie zusätzliche 3 Glins)
-- - Stein (fix)
-- - Chamäleon (ändert Farbe bei Tip darauf)
-- Startbild mit Version und Credits (siehe Forum PlayScreen)
-- - Name für Highscore eintragen
-- Highscore mit Name, Level, Punkten und Datum
-- Orientation
-- Letzte Runde wiederholen

--------------------------------------------------------------------------------------

-- Use this function to perform your initial setup
function setup()
	global_strMessage = "*** Welome to Glin v3.1.2 ***"
	global_anzGlinsInAnimation = 0 -- Befindet sich ein Glin im freien Fall
	global_bitGameOver = 0 -- Ist das Spiel zu Ende
	global_singleGlinJoker = 1 -- Joker Counter
	global_enableGlinJoker = 0 -- Joker einschalten (oben links)

	displayMode(FULLSCREEN)
	supportedOrientations(LANDSCAPE_ANY)

	GF = GlinField() -- Spielfled mit 100 Glins
	LH = LevelHandler() -- Verwaltet Punte und Levels
	PR = Processor() -- Enthält alle Algorithmen
end

-- Aufruf fuer neuen Level
function newGlinField()
	GF = GlinField()
end

-- This function gets called once every frame
function draw()
	-- Draw Glin
	GF:draw(PR, LH)
end

-- This function gets called once every touch
function touched(touch)
	-- Handle touch
	GF:touched(touch, PR, LH)
end

--------------------------------------------------------------------------------------
--# GlinField
--------------------------------------------------------------------------------------
GlinField = class()

-- Konstruktor
function GlinField:init()
	-- Farben

	-- Pastell (Maya)
	-- self.RGBColorSet = {color(255, 0, 0, 0), color(47, 97, 191, 255), color(56, 167, 119, 255), color(160, 98, 195, 255), color(185, 67, 77, 255)}

	-- Pink (Corinne)
	-- self.RGBColorSet = {color(255, 0, 0, 0), color(189, 70, 145, 255), color(189, 137, 167, 255), color(134, 59, 102, 255), color(183, 175, 181, 255)}

	-- Lila (Default)
	self.RGBColorSet = {color(255, 0, 0, 0), color(250, 55, 255, 55), color(250, 123, 255, 123), color(250, 192, 255, 192), color(250, 240, 255, 240)}

	-- Array mit Glins (1. Dimension)
	self.GlinField = {}

	-- Verteilung der Farben
	self.ArrColorCounter = {0,0,0,0}

	-- Init GlinField with Glins
	for x = 1,10 do
		-- Array mit Glins (2. Dimension)
		self.GlinField[x] = {}

		for y = 1,10 do
			self.GlinField[x][y] = Glin(x,y)
		end
	end

	-- Mesh (fur schnellere Animation)
	self.myMesh = mesh() -- Mesh Objekt
	self.rects = {} -- Array mit Rechtecken
	self:setMesh() -- Init Mesh
end

-- This function gets called once every frame
function GlinField:draw(PR, LH)
	-- Wenn sich Glins in Bewegung befinden, aktualisiere Positionen und myMesh
	if global_anzGlinsInAnimation > 0 then
		PR:calcAnimatedPos(self.GlinField, LH)
		self:updateMesh()
	end

	-- Rendere GlinField
	background(25, 25, 25, 255)
	self.myMesh:draw()

	-- Zeichne Menues
	------------------------------------------------------------------------------
	-- 3 Rahmen links
	strokeWidth(2)
	fill(117, 52, 119, 74)
	rect(20, 600, 280, 55)

	fill(144, 39, 148, 98)
	rect(20, 445, 280, 145)
	rect(20, 350, 280, 85)

	-- Config für Texte in den Rahmen links
	fill(255)
	textMode(CORNER)
	font("Noteworthy-Bold")
	fontSize(18)

	-- Texte
	text("Highscore", 40, 695)
	text(string.format("%d -> %d", LH.HighScoreLevel, LH.HighScore), 160, 695)

	text(string.format("Level %d", LH.Level), 40, 612)
	text(string.format("%d (%d)", ( LH.NeededPoints ), ( LH.NeededLevelPoints )), 160, 612)

	text("Punkte", 40, 550)
	text(( LH.Points ), 160, 550)

	text("Extrapunkte", 40, 510)
	text(( LH.ExtraPoints), 160, 510)

	text("Totalpunkte", 40, 460)
	text(( LH.TotalPoints + LH.Points + LH.ExtraPoints ), 160, 460)

	text("Differenz", 40, 400)
	pushStyle()
	local tmpP = ( LH.NeededPoints-(LH.TotalPoints + LH.Points + LH.ExtraPoints) )
	if tmpP < 0 then
		fill(65, 236, 123, 255)
	end
	text(tmpP, 160, 400)
	popStyle()

	-- Wenn Joker aktiviert ist, grün, sonst weiss
	pushStyle()
	text("Anzahl Joker", 40, 360)
	if global_enableGlinJoker == 1 and global_singleGlinJoker > 0 then
		fill(65, 236, 123, 255)
	end
	text(global_singleGlinJoker, 160, 360)
	popStyle()

	-- Farbverteilung
	pushStyle()
	text(self.ArrColorCounter[1], 58, 307)
	text(self.ArrColorCounter[2], 123, 307)
	text(self.ArrColorCounter[3], 190, 307)
	text(self.ArrColorCounter[4], 258, 307)

	fill(self.RGBColorSet[2])
	rect(30, 310, 20, 20)
	fill(self.RGBColorSet[3])
	rect(95, 310, 20, 20)
	fill(self.RGBColorSet[4])
	rect(165, 310, 20, 20)
	fill(self.RGBColorSet[5])
	rect(230, 310, 20, 20)
	popStyle()

	-- Weisse Linie
	stroke(255)
	strokeWidth(5)
	line(40,500,280,500)
	strokeWidth(0)

	-- Statusmeldung oberhalb des Spielfeldes
	textMode(CENTER)
	text(global_strMessage, 645,710)

	-- Reload Button
	sprite("Planet Cute:Star", 980,720,55)

end

-- This function gets called once every touch
function GlinField:touched(touch, PR, LH)
	-- Wenn der Finger gehoben wird, keine Animation mehr im Gange ist
	if touch.state == ENDED and global_anzGlinsInAnimation == 0 then
		-- Hole y/y Koordinaten des Berührungspunktes
		local xtp = math.floor(((CurrentTouch.x)-340)/60)+1
		local ytp = math.floor((CurrentTouch.y-50)/60)+1

		-- Wenn ein fabiges Glin gedrückt wurde
		if xtp >= 1 and xtp <= 10 and ytp >= 1 and ytp <= 10
			and self.GlinField[xtp][ytp].Color ~= 0 and global_bitGameOver == 0 then
			-- Setze Stausmeldung neu
			global_strMessage = ""

			-- Handle Touch
			PR:processTouch(xtp, ytp, self.GlinField, LH)
			self:updateMesh()

			-- Restart
		elseif xtp > 10 and ytp > 10 then

			setup()
		end

		-- Joker ein/ausschalten
		if (xtp == -2 or xtp == -3) and ytp == 6
			and global_enableGlinJoker == 0 and global_bitGameOver == 0 then
			global_enableGlinJoker = 1
		else
			global_enableGlinJoker = 0
		end

		-- Debug
		--global_strMessage = string.format("%d %d",xtp,ytp)
	end
end

-- Init myMesh Objekt
function GlinField:setMesh()

	for x = 1, 10 do
		for y = 1, 10 do
			-- Fuege Reckteck hinzu
			local i = self.myMesh:addRect(317.5+(x*60), 27.5+(y*60), 55, 55)

			-- Setzte richtige Farbe
			local c = self.RGBColorSet[self.GlinField[x][y].Color+1]
			self.myMesh:setRectColor(i, c)

			-- Aktualisiere Farbverteilung
			self.ArrColorCounter[self.GlinField[x][y].Color] =
			self.ArrColorCounter[self.GlinField[x][y].Color] + 1

			-- Speichere das Rechteck separat in Array ab
			table.insert(self.rects, i)
		end
	end
end

-- Aktualisiere alle Rechecke in myMesh mit aktuellen Farben/Positionen
function GlinField:updateMesh()
	self.ArrColorCounter = {0, 0, 0, 0}
	local x = 0
	local y = 0

	for k,v in ipairs(self.rects) do
		-- Transformiere 1 - 100 Index in x/y Koordinaten
		if k%10 == 0 then x = 10 else x = k%10 end
		y = math.ceil(k/10)

		-- Aktualisiere Farben
		local c = self.RGBColorSet[self.GlinField[x][y].Color+1]
		self.myMesh:setRectColor(v, c)

		-- Aktualisiere Farbverteilung
		if self.GlinField[x][y].Color ~= 0 then
			self.ArrColorCounter[self.GlinField[x][y].Color] =
			self.ArrColorCounter[self.GlinField[x][y].Color] + 1
		end

		-- Aktualisiere Rechteckpositionen
		self.myMesh:setRect(v, 317.5+self.GlinField[x][y].xPosCord,
		27.5+self.GlinField[x][y].yPosCord, 55, 55)
	end
end

--------------------------------------------------------------------------------------
--# Glin
--------------------------------------------------------------------------------------
Glin = class()

-- Konstruktor
function Glin:init(x, y)

	-- Color
	self.Color = math.random(4)

	-- Postition
	self.xPos = x -- 1-10
	self.yPos = y -- 1-10
	self.TargetyPos = y -- Fuer Animation
	self.xPosCord = x * 60 -- Fuer Animation
	self.yPosCord = y * 60 -- Fuer Animation

	-- Glin Status und Typ
	-- 0: nicht markiert, 1: markiert
	self.State = 0

	-- -1: Idle, 0: Ready to fall, 1: Move down, 2: Move up, 3; Move slow down
	self.AnimationState = -1

	-- 1: normal, 2-n: (z.B. Bomb, Star etc.) todo
	-- self.Type = 1
end

--------------------------------------------------------------------------------------
--# LevelHandler
LevelHandler = class()
--------------------------------------------------------------------------------------

-- Konstruktor
function LevelHandler:init()
	-- Level Konstanten
	self.factorPoints = 1000 -- Level Erhöhungsschritt
	self.factorColor = 1.75 -- Je mehr Farbnachbarn, je höhere Punktzahl (höher: einfacher)
	self.factorProgress = 1.05 -- Steigende Schwierigkeit (progressiv) (höher: schwerer)

	-- Punkte während Level
	self.Points = 0 -- Zwischenpunkte in aktuellem Level
	self.ExtraPoints = 0 -- Extrapunkte in aktuellem Level

	-- Levelhandling
	self.Level = 1
	self.NeededLevelPoints = self.factorPoints -- Benoetigte Punkte fuer diesen Level
	self.NeededPoints = self.factorPoints -- Benoetigte Punkte Total
	self.TotalPoints = 0 -- Gesamtpunkte kummuliert (wird nur am Levelende gesetzt)

	-- Highscore
	self.HighScore = readProjectData("hs")
	self.HighScoreLevel = readProjectData("hsl")
	if self.HighScore == nil or self.HighScoreLevel == nil then
		self.HighScore = 0
		self.HighScoreLevel = 0
	end
end

-- Bereite naechsten Level vor
function LevelHandler:nextLevel()
	-- Erhöhe Level und aktualisiere kummulierte Gesamtpunkte
	self.Level = self.Level + 1

	local tmpNeededPoints = self.NeededPoints -- fuer Differenz

	self.NeededPoints = math.ceil((self.NeededPoints + self.factorPoints) * self.factorProgress)
	self.NeededLevelPoints = self.NeededPoints - tmpNeededPoints
	self.TotalPoints = self.TotalPoints + math.ceil(self.Points + self.ExtraPoints )

	-- Setzte Zwischenpunkte für neuen Level zurück
	self.Points = 0
	self.ExtraPoints = 0
end

-- Berechne Punkte
function LevelHandler:calcPoints(GF)
	local tmpExtraPoints = 0 -- Extrapunkte (3x3er Block)
	local tmpAnzColor = 0 -- Anzahl zusammenhaengende farbige Glins

	for x = 1,10 do
		for y = 1,10 do
			if GF[x][y].State == 1 then
				local curColor = GF[x][y].Color

				-- 3x3er Block mit aktuellem Glin in der Mitte? Extrapunkte
				if x > 1 and x < 10 and y > 1 and y < 10
					and curColor == GF[x-1][y].Color
					and curColor == GF[x+1][y].Color
					and curColor == GF[x-1][y+1].Color
					and curColor == GF[x][y+1].Color
					and curColor == GF[x+1][y+1].Color
					and curColor == GF[x-1][y-1].Color
					and curColor == GF[x][y-1].Color
					and curColor == GF[x+1][y-1].Color then

					tmpExtraPoints = tmpExtraPoints + 500
					if global_singleGlinJoker == 0 then
						global_singleGlinJoker = global_singleGlinJoker + 1 -- Joker
					end

					-- 3x3er Block mit Loch mit aktuellem Glin links unten? Extrapunkte
				elseif x < 9 and y < 9
					and curColor == GF[x+1][y].Color
					and curColor == GF[x+2][y].Color
					and curColor == GF[x+2][y+1].Color
					and curColor == GF[x+2][y+2].Color
					and curColor == GF[x+1][y+2].Color
					and curColor == GF[x][y+2].Color
					and curColor == GF[x][y+1].Color then

					tmpExtraPoints = tmpExtraPoints + 250

				-- Ein "+" (3x3) mit aktuellem Glin in der Mitte? Extrapunkte
				elseif x > 1 and x < 10 and y > 1 and y < 10
					and curColor == GF[x-1][y].Color
					and curColor == GF[x+1][y].Color
					and curColor == GF[x][y+1].Color
					and curColor == GF[x][y-1].Color then

					tmpExtraPoints = tmpExtraPoints + 150
				end
				-- Erhoehe Multiplikator
				tmpAnzColor = tmpAnzColor + 1
			end
		end
	end

	-- Aktualisiere Punkte
	self.ExtraPoints = self.ExtraPoints + math.ceil(tmpExtraPoints)
	self.Points = self.Points + math.ceil(tmpAnzColor * tmpAnzColor * self.factorColor)
end

-- Berechne anhand der uebriggebliebenen Glins die Extrapunkte am Ende einer Runde
function LevelHandler:calcExtraPointsEndRound(GF)
	local tmpAnzColorGlins = 0 -- Uebriggebliebene Glins mit Farbe
	local tmpExtraPoints = 0 -- Extrapunkte

	for x = 1,10 do
		if GF[x][1].Color ~= 0 then
			for y = 1,10 do
				-- Zaehle uebriggebliebene Glins mit Farbe am Ende des Levels
				if GF[x][y].Color ~= 0 then
					tmpAnzColorGlins = tmpAnzColorGlins + 1
				end
			end
		end
	end

	-- Je weniger Glins am Ende der Runde uebrig, je mehr Extrapunkte
	if tmpAnzColorGlins == 0 then
		tmpExtraPoints = 750
		global_singleGlinJoker = global_singleGlinJoker + 1 -- Joker
		elseif tmpAnzColorGlins < 10 then
			tmpExtraPoints = math.ceil(500/tmpAnzColorGlins)
		end

		-- Aktualisiere Statusmeldung und Extrapunkte
		global_strMessage = string.format("Punkte Levelende: %d",
		self.Points + self.ExtraPoints + tmpExtraPoints)
		self.ExtraPoints = math.ceil( self.ExtraPoints + tmpExtraPoints)
	end

	--------------------------------------------------------------------------------------
	--# Processor
	--------------------------------------------------------------------------------------
	Processor = class()

	-- Konstruktor
	function Processor:init()
		bitCleanUpNeeded = 0
	end

	-- Behandelt einen Spielzug
	function Processor:processTouch(xtp, ytp, GF, LH)

		-- Markiere Farbnachbarn
		self:markNeigbours(GF, GF[xtp][ytp], GF[xtp][ytp].Color)

		-- Einzelnes Glin gedrückt
		if global_singleGlinJoker > 0 and GF[xtp][ytp].Color ~= 0
			and self:hasGlinNeigbours(GF, xtp, ytp) == 0 and global_enableGlinJoker == 1 then

			global_singleGlinJoker = global_singleGlinJoker - 1
			global_enableGlinJoker = 0
			self:markSingleGlin(GF, GF[xtp][ytp])
		end

		-- Erhoehe Punkte
		LH:calcPoints(GF)

		-- Fuehre Spielzug aus
		self:processGlinField(GF, LH)

	end

	-- Beende Runde (wird in Methode calcAnimatedPos() aufgerufen)
	function Processor:endRound(GF, LH)
	-- Zaehle Uebriggebliebene Glins
	LH:calcExtraPointsEndRound(GF)

	-- Naechster Level geschafft?
	if (LH.TotalPoints + LH.Points + LH.ExtraPoints) >= LH.NeededPoints then
		-- Erzeuge neues GlinField
		LH:nextLevel()
		newGlinField()
	else
		local tmpHS = math.ceil(LH.TotalPoints + LH.Points + LH.ExtraPoints)

		-- New HighScore?
		if tmpHS > LH.HighScore then
			LH.HighScore = tmpHS
			LH.HighScoreLevel = LH.Level
			saveProjectData("hs", tmpHS)
			saveProjectData("hsl", LH.Level)
			global_strMessage = string.format("*** New HighScore: %d ***", LH.HighScore)
		else
			global_strMessage = "*** Game over ***"
		end

		-- Spiel zu Ende
		global_bitGameOver = 1
	end
end

-- Hat ein Glin Farbnachbarn?
function Processor:hasGlinNeigbours(GF, x, y)
	local tmpColor = GF[x][y].Color
	local tmpNeighbour = 0

	-- Check links
	if x > 1 then
		if GF[x-1][y].Color == tmpColor then
			tmpNeighbour = 1
		end
	end

	-- Check rechts
	if x < 10 then
		if GF[x+1][y].Color == tmpColor then
			tmpNeighbour = 1
		end
	end

	-- Check unten
	if y > 1 then
		if GF[x][y-1].Color == tmpColor then
			tmpNeighbour = 1
		end
	end

	-- Check oben
	if y < 10 then
		if GF[x][y+1].Color == tmpColor then
			tmpNeighbour = 1
		end
	end

	return tmpNeighbour
end

-- Gibt es irgendwo noch Farbnachbarn?
function Processor:hasNeigbours(GF)
	-- Pruefe fuer Zeile und Reihe 1-9 oben und rechts auf Farbnachbarn
	-- TODO Spalte ganz rechts prüfen
	for x = 1,9 do
		-- Beachte nur Reihen, wo Glins vorhanden sind
		if GF[x][1].Color ~= 0 then
			for y = 1,9 do
				local tmpColor = GF[x][y].Color
				if tmpColor ~= 0
					and (tmpColor == GF[x+1][y].Color or tmpColor == GF[x][y+1].Color) then

					return 1 -- Es hat Farbnachbarn
				end
			end
		end
	end

	return 0 -- Es hat keine Farbnachbarn
end

-- Markiert ein einzelnes Glin
function Processor:markSingleGlin(GF, Glin)
	GF[Glin.xPos][Glin.yPos].State = 1
end

-- Markiert alle Glins mit demselben Farbcode per Status (Rekursiv)
function Processor:markNeigbours(GF, Glin, Color)

	if Glin.xPos > 1 then
		if GF[Glin.xPos-1][Glin.yPos].Color == Color and
			GF[Glin.xPos-1][Glin.yPos].State == 0 then

			GF[Glin.xPos-1][Glin.yPos].State = 1
			self:markNeigbours(GF, GF[Glin.xPos-1][Glin.yPos], Color)
		end
	end

	if Glin.xPos < 10 then
		if GF[Glin.xPos+1][Glin.yPos].Color == Color and
			GF[Glin.xPos+1][Glin.yPos].State == 0 then

			GF[Glin.xPos+1][Glin.yPos].State = 1
			self:markNeigbours(GF, GF[Glin.xPos+1][Glin.yPos], Color)
		end
	end

	if Glin.yPos > 1 then
		if GF[Glin.xPos][Glin.yPos-1].Color == Color and
			GF[Glin.xPos][Glin.yPos-1].State == 0 then

			GF[Glin.xPos][Glin.yPos-1].State = 1
			self:markNeigbours(GF, GF[Glin.xPos][Glin.yPos-1], Color)
		end
	end

	if Glin.yPos < 10 then
		if GF[Glin.xPos][Glin.yPos+1].Color == Color and
			GF[Glin.xPos][Glin.yPos+1].State == 0 then

			GF[Glin.xPos][Glin.yPos+1].State = 1
			self:markNeigbours(GF, GF[Glin.xPos][Glin.yPos+1], Color)
		end
	end
end

-- Fuehre Spielzug aus
function Processor:processGlinField(GF, LH)
	-- Setze bei allen markierten Status auf 0 und Farbcode auf 0
	for x = 1,10 do
		for y = 1,10 do
			-- Graues Glin, das verschwindet
			if GF[x][y].State == 1 then
				GF[x][y].State = 0
				GF[x][y].Color = 0

				-- Handling der Animation -----------------------------------------------------------
				-- Farbiges Glin, das ev. herunterfaellt (weil es leere Glins unterhalb hat)
			elseif GF[x][y].Color ~= 0 then
				-- Wie viele leere Glins sind unterhalb von mir?
				local tmpLeer = 0
				for yleer = 1, y do
					if GF[x][yleer].Color == 0 then
						tmpLeer = tmpLeer + 1
					end
				end

				-- Es hat leere Glins unterhalb eines farbigen Glins
				if tmpLeer > 0 then
					-- Aendere Zielposition des Glin um Anzahl leere Glins unterhalb
					GF[x][y].TargetyPos = GF[x][y].yPos - tmpLeer

					-- Mark as ready to fall down
					GF[x][y].AnimationState = 0

					-- Ein Glin mehr in Bewegung
					global_anzGlinsInAnimation = global_anzGlinsInAnimation + 1

					-- Bitte bei Gelegenheit aufraemen
					bitCleanUpNeeded = 1
				end
			end
		end
	end

	-- Wenn Animation abgeschlossen ist und es leere Spalten hat -> "Auf einen Ruck" aufschliessen
	local tmpAnzER = self:anzEmptyRows(GF) -- Anzahl leere Spalten
	if global_anzGlinsInAnimation == 0 and tmpAnzER > 0 then
		-- leftFill (leere vertikale Reihen ersetzen)
		for i = 1, tmpAnzER do
			for j = 1,9 do
				self:leftFill(j, GF)
			end
		end
	end

	-- Wenn Animation abgeschlossen ist und keine Farbnachbarn mehr vorhanden sind, beende Level
	if global_anzGlinsInAnimation == 0 and self:hasNeigbours(GF) == 0 then
		self:endRound(GF, LH)
	end
end

-- Aktualisiert die Positionen aller Glins, welche in Bewegung sind.
-- Wird aus Draw-Methode aufgerufen
function Processor:calcAnimatedPos(GF, LH)
	for x = 1,10 do
		for y = 1,10 do
			local tmpAniState = GF[x][y].AnimationState
			local tmpYCur = GF[x][y].yPosCord
			local tmpYTarget = GF[x][y].TargetyPos * 60

			-- Initiale Abwaertsbewegung
			if tmpAniState == 0 then
				if tmpYCur > tmpYTarget then
					GF[x][y].yPosCord = tmpYCur - 30
				elseif tmpYCur == tmpYTarget then
					GF[x][y].AnimationState = 1
				end
			-- Aufwaertsbewegung nach Aufprall
			elseif tmpAniState == 1 then
				if tmpYCur >= tmpYTarget and tmpYCur <= (tmpYTarget+5) then
					GF[x][y].yPosCord = tmpYCur + 1
				elseif tmpYCur == (tmpYTarget+6) then
					GF[x][y].AnimationState = 2
				end
			-- langsamerere, finale Abwaertsbewegung
			elseif tmpAniState == 2 then
				if tmpYCur > tmpYTarget then
					GF[x][y].yPosCord = tmpYCur - 0.5

					-- Glin an Zielposition angekommen
				elseif tmpYCur == tmpYTarget then
					GF[x][y].AnimationState = -1 -- Setzte Animationsstatus auf Idle

					-- Ein Glin weniger in Bewegung
					global_anzGlinsInAnimation = global_anzGlinsInAnimation - 1

					-- Wenn letztes Glin an die richtige Stelle animiert worden,
					-- bereigige Postionen und Farben
					if global_anzGlinsInAnimation == 0 and bitCleanUpNeeded == 1 then

						self.bitCleanUpNeeded = 0
						self:cleanPosUp(GF)

						-- Wenn Animation abgeschlossen ist und keine Farbnachbarn mehr
						-- vorhanden sind, beende Level
						if self:hasNeigbours(GF) == 0 then
							self:endRound(GF, LH)
						end
					end
				end
			end
		end
	end
end

function Processor:cleanPosUp(GF)
	-- Gravity
	local tmpIntRows0 = 0 -- Anzahl vertikaler Leerzeilen fuer Anzahl Durchgaenge von leftFill()
	for x = 1,10 do
		tmpIntRows0 = tmpIntRows0 + self:gravity(x, GF)
	end

	-- leftFill (leere vertikale Reihen ersetzen)
	for i = 1, tmpIntRows0 do
		for j = 1,9 do
			self:leftFill(j, GF)
		end
	end
end

-- Ersetzt leere Glins einer bestimmten Spalte x mit farbigen Glins
function Processor:gravity(x, GF)
	-- Vertikaler Loop und nur Glins mit Fabe in tmpTab speichern
	local tmpTab ={0,0,0,0,0,0,0,0,0,0}
	local tmpIndex = 0

	for y = 1,10 do
		if GF[x][y].Color ~= 0 then
			tmpIndex = tmpIndex + 1
			tmpTab[tmpIndex] = GF[x][y].Color
		end
	end

	-- Grid mit soeben erstellter vertikalen Tab ersetzen
	for y = 1 , 10 do
		GF[x][y].Color = tmpTab[y]
		GF[x][y].yPosCord = y * 60
	end

	-- Wenn Spalte vertikal nur leere Glins hat, dies zurueckmelden
	if tmpIndex == 0 then
		return 1
	else
		return 0
	end
end

-- Wenn unterstes Glin einer Spalte x leer ist, dann schiebe ganze Spalte 1 nach links
function Processor:leftFill(x, GF)
	if GF[x][1].Color == 0 then
		for y = 1,10 do
			GF[x][y].Color = GF[x+1][y].Color
			GF[x+1][y].Color = 0
		end
	end
end

-- Gib Anzahl leere Spalten zurück
function Processor:anzEmptyRows(GF)
	local tmpAnzEmptyRows = 10

	for x = 1, 10 do
		local tmpRowIsEmpty = 1 -- Annahme, dass Spalte leer ist

		for y = 1, 10 do
			-- Wenn ein farbiges Glin vorhanden ist, markiere Spalte als nicht leer (0)
			if GF[x][y].Color ~= 0 then
				tmpRowIsEmpty = 0
			end
		end
		-- Wenn Spalte nicht leer ist, vermindere Zaehler um 1
		if tmpRowIsEmpty == 0 then
			tmpAnzEmptyRows = tmpAnzEmptyRows - 1
		end
	end

	return tmpAnzEmptyRows
end
