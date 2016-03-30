GameVersionCheck(GameName)
{
	if GameName = GTAVC
	{
		; Check which version of Vice City is used (this offsets the memory addresses)
		Value := Memory(3, 0x00608578, 1)
		if Value = 0x5D
			Return 0 ; Version 1.0
		if Value = 0x81
			Return 8 ; Version 1.1
		if Value = 0x5B
			Return -0xFF8 ; Version Steam
		if Value = 0x44
			Return -0x2FF8 ; Version Japanese
		Msgbox Error`: The script could not determine the version of GTA Vice City %Value%
	}
	Else if GameName = GTASA
	{
		; Check which version of San Andreas is used (this offsets the memory addresses)
		if Memory(3, 0x0082457C, 4) = 0x94BF
			return 0 ; Version 1.0 US
		if Memory(3, 0x008245BC, 4) = 0x94BF
			return 0 ; Version 1.0 EU/AUS or 1.0 US Hoodlum or 1.0 Downgraded
		if Memory(3, 0x008252FC, 4) = 0x94BF
			return 0x2680 ; Version 1.01 US
		if Memory(3, 0x0082533C, 4) = 0x94BF
			return 0x2680 ; Version 1.01 EU/AUS or 1.01 Deviance or 1.01 Downgraded
		if Memory(3, 0x0085EC4A, 4) = 0x94BF
			return 0x75130 ; Version 3.0 Steam
		if Memory(3, 0x0085DEDA, 4) = 0x94BF
			return 0x75770 ; Version 1.01 Steam ?
		ModuleBase := GetProcessBaseAddress()
		if Memory(3, ModuleBase + 0x0046D940, 4) = 0x8B55FF8B
			return (ModuleBase - 0x00400000 + 0x77970) ; NewSteam r2 version
		Msgbox Error`: The script could not determine the version of GTA San Andreas
	}
	Else if GameName = GTA3
	{
		; Check which version of III is used (this offsets the memory addresses)
		if Memory(3, 0x005C1E70, 4) = 0x53E58955
			return -0x10140 ; Version 1.0 NoCD		
		if Memory(3, 0x005C2130, 4) = 0x53E58955
			return -0x10140 ; Version 1.1 NoCD
		if Memory(3, 0x005C6FD0, 4) = 0x53E58955
			return  0 ; Version 1.1 Steam
		if Memory(3, 0x009F3C17, 4) = 0x6AEC8B55
			return -0x21E0 ; Version Japanese
		Msgbox Error`: The script could not determine the version of GTA 3
	}
	Else if GameName = Bully
	{
		; Check which version of Bully is used (this offsets the memory addresses)
		if Memory(3, 0x0091BF70, 5, "Ascii") = "Coll\"
			return 0 ; Version Steam 1.2 and retail 1.153
		Msgbox Error`: The script could not determine the version of Bully
	}
	Else if GameName = SimpsonsHAR
	{
		return 0 ; No version checking yet.
	}
	Else 
		msgbox Error`: Invalid game`: %GameName%.
} 
