-------------------------------------------------------------------
-- Module is used for point configuration and interaction with the UI
-------------------------------------------------------------------
-- Copyright 2021-2023 Vladislav Kadulin <spanky@yandex.ru>
-- Licensed to the GNU General Public License v3.0

local uci = require("luci.model.uci")
local sys = require("luci.sys")

config = {}

local CFG = uci:get_all("gpoint")

-- Status table
local STATUS = {
    APP = {
        MODEM_OK = { false, "OK" },
        MODEM_ERROR = { true, "Modem error. Select modem in the settings!" },
        PORT_ERROR = { true, "Modem Port error. Select port in the settings!" }
    },
    SERVER = {
        SERVICE_ON = { false, "OK" },
        SERVICE_OFF = { true, "OFF" },
        IP_ERROR = { true, "Server address error. Enter the server address!" },
        PORT_ERROR = { true, "Server port error. Set the server port!" },
        LOGIN_ERROR = { true, "Login (ID) error. Specify the device login!" }
    },
    LOCATOR = {
        SERVICE_ON = { false, "OK" },
        SERVICE_OFF = { true, "OFF" },
        API_KEY_ERROR = { true, "Yandex Locator: API key not found!" },
        WIFI_IFACE_ERROR = { true, "Yandex Locator: Wi-Fi interface not found!" }
    },
    FILTER = {
        SERVICE_ON = { false, "OK" },
        SERVICE_OFF = { true, "OFF" }
    }
}

local MODEM = {
    DELL = {
        START = "AT+GPS=1",
        STOP = "AT+GPS=0"
    },
    QUECTEL = {
        START = "AT+QGPS=1",
        STOP = "AT+QGPSEND"
    },
    SIERRA = {
        START = "$GPS_START",
        STOP = "$GPS_STOP"
    },
    SIMCOM = {
        START = "AT+CGPS=1,1",
        STOP = "AT+CGPS=0,1"
    },
    MEIGLINK = {
        START = "AT+GPSRUN=0,30,100,0,1",
        STOP = "AT+GPSSTOP"
    },
    HUAWEI = {
        START = "AT^WPDGP",
        STOP = "AT^WPEND"
    },
    UBLOX = {
        START = "-",
        STOP = "-"
    }
}


-----------------------------------------------------------------------------------
-- APP (Modem Settings)
-- 1.Checking the configuration for the presence of the modem name
-- 2.Checking the presence of the port in the configuration and whether
-- it is in the list of devices, if the device is unavailable, we return a warning
-- 3. return err + modem data (name modem and NMEA port modem)
-----------------------------------------------------------------------------------
function config.getModemData()

    local err = {}
    local modem = {
        start = "-",
        stop = "-",
        name = "-",
        port = "-",
        mode = "-"
    }

    if not CFG.modem_settings.modem and CFG.modem_settings.modem == "mnf" then
        err = STATUS.APP.MODEM_ERROR
    elseif CFG.modem_settings.port and CFG.modem_settings.port == "pnf" then
        err = STATUS.APP.PORT_ERROR
    else
        err = STATUS.APP.MODEM_OK
    end

    if not err[1] then
        if string.find(CFG.modem_settings.modem, "Quectel") then
            modem.start = MODEM.QUECTEL.START
            modem.stop = MODEM.QUECTEL.STOP
        elseif string.find(CFG.modem_settings.modem, "Sierra") then
            modem.start = MODEM.SIERRA.START
            modem.stop = MODEM.SIERRA.STOP
        elseif string.find(CFG.modem_settings.modem, "U-Blox") then
            modem.start = MODEM.UBLOX.START
            modem.stop = MODEM.UBLOX.STOP
        elseif string.find(CFG.modem_settings.modem, "Simcom") then
            modem.start = MODEM.SIMCOM.START
            modem.stop = MODEM.SIMCOM.STOP
        elseif string.find(CFG.modem_settings.modem, "MEIGLink") then
            modem.start = MODEM.MEIGLINK.START
            modem.stop = MODEM.MEIGLINK.STOP
        elseif string.find(CFG.modem_settings.modem, "Huawei") then
            modem.start = MODEM.HUAWEI.START
            modem.stop = MODEM.HUAWEI.STOP
        elseif string.find(CFG.modem_settings.modem, "Dell") then
            modem.start = MODEM.DELL.START
            modem.stop = MODEM.DELL.STOP
        end
        modem.name = CFG.modem_settings.modem
        modem.port = CFG.modem_settings.port
        modem.mode = CFG.modem_settings.mode
        if modem.mode == "gpsd" then
            modem.gpsd_device = CFG.modem_settings.port
            modem.gpsd_ip = CFG.modem_settings.gpsd_ip
            modem.gpsd_port = CFG.modem_settings.gpsd_port
            modem.gpsd_speed = CFG.modem_settings.gpsd_speed
            modem.gpsd_listen_globally = CFG.modem_settings.listen_globally
        end
    end
    return err, modem
end

-----------------------------------------------------------------------------------
-- Remote Server
-- 1.We check whether the server service is enabled or not.
-- 2.The correctness of the completed forms is checked such as address, login, port, etc ...
-- 3.We return the absence of an error and the server configuration data otherwise an error, nil ...
-----------------------------------------------------------------------------------
function config.getServerData()

    local err = {}
    local server = {
        address = "",
        port = "",
        protocol = "",
        login = "",
        password = "",
        frequency = "",
        blackbox = {
            enable = "",
            cycle = "",
            size = 0
        }
    }

    if not CFG.server_settings.server_enable then
        err = STATUS.SERVER.SERVICE_OFF
    elseif not CFG.server_settings.server_ip then
        err = STATUS.SERVER.IP_ERROR
    elseif not CFG.server_settings.server_port then
        err = STATUS.SERVER.PORT_ERROR
    elseif not CFG.server_settings.server_login then
        err = STATUS.SERVER.LOGIN_ERROR
    else
        err = STATUS.SERVER.SERVICE_ON
    end

    if not err[1] then
        server.address = CFG.server_settings.server_ip
        server.port = CFG.server_settings.server_port
        server.protocol = CFG.server_settings.proto
        server.login = CFG.server_settings.server_login

        if server.protocol == "wialon" then
            server.password = CFG.server_settings.server_password or "NA"
            server.frequency = CFG.server_settings.server_frequency or 5
            server.blackbox.enable = CFG.server_settings.blackbox_enable and true or false
            server.blackbox.cycle = CFG.server_settings.blackbox_cycle and true or false
            server.blackbox.size = CFG.server_settings.blackbox_max_size or 1000
        elseif server.protocol == "traccar" then
            server.frequency = CFG.server_settings.server_frequency or 5
        end

        return err, server
    else
        return err, nil
    end
end

-----------------------------------------------------------------------------------
-- Yandex Locator
-- 1.Check Yandex Locator service enable/disable
-- 2.Check Yandex API key status enable/disable
-- 3.Check Yandex Locator interface status enable/disable
-----------------------------------------------------------------------------------
function config.getLoctorData()

    local err = {}
    local locator = {
        enable = false,
        iface = "",
        key = ""
    }

    if not CFG.service_settings.ya_enable then
        err = STATUS.LOCATOR.SERVICE_OFF
    elseif not CFG.service_settings.ya_key then
        err = STATUS.LOCATOR.API_KEY_ERROR
    elseif not CFG.service_settings.ya_wifi and CFG.service_settings.ya_wifi == "wnf" then
        err = STATUS.LOCATOR.WIFI_IFACE_ERROR
    else
        err = STATUS.LOCATOR.SERVICE_ON
    end

    if not err[1] then
        locator.iface = CFG.service_settings.ya_wifi
        locator.key = CFG.service_settings.ya_key
        return err, locator
    else
        return err, nil
    end
end

-----------------------------------------------------------------------------------
-- GpointFilter
-- 1. Checking for the filter library
-- 2. Check GpointFilter service enable/disable
-- 3. Make the settings, if there are none, then we apply the default settings
-----------------------------------------------------------------------------------
function config.getFilterData()

    local err = {}
    local filter = {
        enable = false,
        changes = 0,
        hash = '0',
        speed = 0
    }

    if not CFG.service_settings.filter_enable then
        err = STATUS.FILTER.SERVICE_OFF
    else
        err = STATUS.FILTER.SERVICE_ON
        filter.enable = true
        filter.changes = tonumber(CFG.service_settings.filter_changes or 3)
        filter.hash = tostring(CFG.service_settings.filter_hash or '7')
        filter.speed = tonumber(CFG.service_settings.filter_speed or 2)
    end

    return err, filter
end

-----------------------------------------------------------------------------------
-- KalmanFilter
-- 1. Checking for the kalman filter library
-- 2. Check KalmanFilter service enable/disable
-- 3. Make the settings, if there are none, then we apply the default settings
-----------------------------------------------------------------------------------
function config.getKalmanData()

    local err = {}
    local filter = {
        enable = false,
        noise = 0
    }

    if not CFG.service_settings.kalman_enable then
        err = STATUS.FILTER.SERVICE_OFF
    else
        err = STATUS.FILTER.SERVICE_ON
        filter.enable = true
        filter.noise = tonumber(CFG.service_settings.kalman_noise or 1.0)
    end

    return err, filter
end

-----------------------------------------------------------------------------------
-- Geofence
-- 1. Checking for the Geofence library
-- 2. Check Geofence service enable/disable
-- 3. Make the settings, if there are none, then we apply the default settings
-----------------------------------------------------------------------------------
function config.getGeofenceData()

    local err = {}
    local geofence = {
        enable = false,
        latitude = 0.0,
        longitude = 0.0,
        area = 153,
        script = false,
        path = "",
        when = "All"
    }

    if not CFG.service_settings.geofence_enable then
        err = STATUS.FILTER.SERVICE_OFF
    else
        err = STATUS.FILTER.SERVICE_ON
        geofence.enable = true
        geofence.latitude = tonumber(CFG.service_settings.geofence_latitude or -77.955806)
        geofence.longitude = tonumber(CFG.service_settings.geofence_longitude or 69.582992)
        geofence.area = tonumber(CFG.service_settings.geofence_area)
        if CFG.service_settings.geofence_script then
            geofence.script = CFG.service_settings.geofence_script == '1' and true or false
            geofence.path = CFG.service_settings.geofence_script_path
            geofence.when = CFG.service_settings.geofence_script_when
        end
    end
    return err, geofence
end

-----------------------------------------------------------------------------------
-- Session ID
-- 1.When initializing the ubus, we write the session id to the uci to work with the UI
-----------------------------------------------------------------------------------
function config.setUbusSessionId(id)
    uci:set("gpoint", "service_settings", "sessionid", id)
    uci:save("gpoint")
    uci:commit("gpoint")
end

return config