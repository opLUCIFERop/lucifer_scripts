Citizen.CreateThread(function()
	while true do
        --This is the Application ID (Replace this with you own)
		SetDiscordAppId(645236279054827531)

        --Here you will have to put the image name for the "large" icon.
		SetDiscordRichPresenceAsset('logo-mk1')
        
        --(11-11-2018) New Natives:

        --Here you can add hover text for the "large" icon.
        SetDiscordRichPresenceAssetText('https://discord.gg/Ttr6fY6')
        
        --Here you will have to put the image name for the "small" icon.
        --SetDiscordRichPresenceAssetSmall('logo-mk3')

        --Here you can add hover text for the "small" icon.
        SetDiscordRichPresenceAssetSmallText('https://discord.gg/Ttr6fY6')

        --It updates every one minute just in case.
		Citizen.Wait(60000)
	end
end)