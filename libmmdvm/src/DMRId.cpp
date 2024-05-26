/*
# Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
*/

#include "DMRLookup.hpp"
#include <assert.h>
#include <iostream>

using namespace std;

#ifdef __cplusplus
  #include "lua.hpp"
#else
  #include "lua.h"
  #include "lualib.h"
  #include "lauxlib.h"
#endif

static CDMRLookup* m_lookup = NULL;

string findByCallsign(string callsign) {
    assert(m_lookup != NULL);
    return m_lookup->find(callsign).c_str();
}

user_t findUserByCallsign(string callsign) {
    assert(m_lookup != NULL);
    return m_lookup->findUser(callsign);
}

void load(string dmrid_file) {
    if(m_lookup == NULL) {
        m_lookup = new CDMRLookup(dmrid_file);
        m_lookup->read();
    }
}

// int main() {
//     load("/Users/mic/Work/radioid/export/DMRIds.dat");
//     string callsign = "BD7MQB";
//     // cout << m_lookup->find(callsign) << endl;
//     user_t user = m_lookup->findUser(callsign);
//     cout << "ID:\t\t" << user.id << endl;
//     cout << "Name:\t\t" << user.name << endl;
//     cout << "City:\t\t" << user.city << endl;
//     cout << "Country:\t" << user.country << endl;
//     return 0;
// }

//so that name mangling doesn't mess up function names
#ifdef __cplusplus
extern "C"{
#endif

static int init (lua_State *L) {
    const char *dmrid_file;
    dmrid_file = luaL_checkstring(L, 1);
    load(string(dmrid_file));

    return 0;
}

static int get_dmrid_by_callsign (lua_State *L) {
    const char *callsign;
    callsign = luaL_checkstring(L, 1);
    lua_pushstring(L, findByCallsign(string(callsign)).c_str());

    return 1;
}

static int get_user_by_callsign (lua_State *L) {
    const char *callsign;
    callsign = luaL_checkstring(L, 1);

    user_t user = findUserByCallsign(string(callsign));

    if (!user.exist()) {
        return 0;
    }
    
    lua_createtable(L, 0, 3);

    lua_pushstring(L, user.name.c_str());
    lua_setfield(L, -2, "name");
    // lua_pushstring(L, user.city.c_str());
    // lua_setfield(L, -2, "city");
    lua_pushstring(L, user.country.c_str());
    lua_setfield(L, -2, "country");

    return 1;
}

//library to be registered
static const struct luaL_Reg mylib [] = {
        {"get_dmrid_by_callsign", get_dmrid_by_callsign},
        {"get_user_by_callsign", get_user_by_callsign},
        {"init", init},
        {NULL, NULL}  /* sentinel */
};

int luaopen_mmdvm(lua_State *L) {
#ifdef OPENWRT
    // Lua 5.1 style
    luaL_register(L, "mmdvm", mylib);
#else
    // Lua 5.3 style
    luaL_newlib(L, mylib);
#endif
	return 1;
}

#ifdef __cplusplus
}
#endif
