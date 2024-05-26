/*
# Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
*/
#ifndef __DMRID__
#define __DMRID__

#include <string>

using namespace std;

struct user_t {
	// int id;
    string name;
	// string city;
    string country;
    bool exist() {
        return name != "";
    }
};

#endif