local ucursor = require "luci.model.uci".cursor()
local json = require "luci.jsonc"

local h_interface = ucursor:get("homebridge", "@homebridge[0]", "interface")

local platform_section=arg[1]
local gen_type=arg[2]

local platform_info = ucursor:get_all("homebridge", platform_section)


function gen(platform_info)
	local device_type
	if platform_info.platform_type == "ReYeelightPlatform" then
		device_type = platform_info.platform_yeelight
	end
	if platform_info.platform_type == "MiPhilipsLightPlatform" then
		device_type = platform_info.platform_philips_light
	end
	if platform_info.platform_type == "MiOutletPlatform" then
		device_type = platform_info.platform_mi_plug
	end
	if platform_info.platform_type == "MiRobotVacuumPlatform" then
		device_type = platform_info.platform_vacuum
	end
	local platform = {
			platform = platform_info.platform_type,
			deviceCfgs = {{
				type = device_type,
				ip = platform_info.ip,
				token = platform_info.token
			}}
	}

	deviceCfg = platform.deviceCfgs[1]

	if platform_info.platform_type == "ReYeelightPlatform" then
		deviceCfg["Name"] = platform_info.alias
		deviceCfg["updatetimer"] = (platform_info.updatetimer == "1")
		deviceCfg["interval"] = tonumber(platform_info.interval)
	end

	if platform_info.platform_type == "MiPhilipsLightPlatform" then
		
		if platform_info.platform_philips_light == "MiPhilipsCeilingLamp" or platform_info.platform_philips_light == "MiPhilipsSmartBulb" then
		deviceCfg["lightName"] = platform_info.alias
		deviceCfg["lightDisable"] = false
		end

		if platform_info.platform_philips_light == "MiPhilipsCeilingLamp" then
		deviceCfg["updatetimer"] = (platform_info.updatetimer == "1") 
		deviceCfg["interval"] = tonumber(platform_info.interval) 
		end 

		if platform_info.platform_philips_light == "MiPhilipsTableLamp2" then
		deviceCfg["mainLightName"] = platform_info.main_light_name
		deviceCfg["secondLightName"] = platform_info.second_light_name
		deviceCfg["secondLightDisable"] = platform_info.second_light_disable == "1"
		deviceCfg["eyecareSwitchName"] = platform_info.eyecare_switch_name
		deviceCfg["eyecareSwitchDisable"] = platform_info.eyecare_switch_disable == "1"
		end
	end

	if platform_info.platform_type == "MiOutletPlatform" then
		deviceCfg["outletName"] = platform_info.alias
		deviceCfg["outletDisable"] = platform_info.outlet_disable == "1"
		deviceCfg["temperatureName"] = platform_info.temperature_name
		deviceCfg["temperatureDisable"] = platform_info.temperature_disable

		if platform_info.platform_mi_plug == "MiPlugBase" or platform_info.platform_mi_plug == "MiIntelligencePinboard" then
			deviceCfg["switchLEDName"] = platform_info.switch_LED_name
			deviceCfg["switchLEDDisable"] = platform_info.switch_LED_disable == "1"
		end
		if platform_info.platform_mi_plug == "MiPlugBaseWithUSB" then
			deviceCfg["switchUSBName"] = platform_info.switch_USB_name
			deviceCfg["switchUSBDisable"] = platform_info.switch_USB_disable == "1"
		end

	end

	if platform_info.platform_type == "MiRobotVacuumPlatform" then
		deviceCfg["robotVacuumName"] = platform_info.alias
		deviceCfg["robotVacuumDisable"] = false
		deviceCfg["enablePauseToCharge"] = true
	end

	return platform
end


local platform
if gen_type == "main" then
	platform = gen(platform_info)
end
if gen_type == "independent" then
	platform = {
	mdns = {
		interface = h_interface 
	},
	bridge = {
		name=platform_info.name,
		username=platform_info.username,
		port=tonumber(platform_info.port),
		pin=platform_info.pin
	},
	accessories = {
	},
	platforms = {{}}
	}
	platform.platforms[1]=gen(platform_info)
end

print(json.stringify(platform, 1))


