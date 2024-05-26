/*
# Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
*/
#ifndef	__DMRLOOKUP__
#define	__DMRLOOKUP__

#include "DMRId.hpp"
#include <string>
#include <unordered_map>

using namespace std;

class CDMRLookup {
public:
	CDMRLookup(const string& filepath);
	virtual ~CDMRLookup();

	bool read();

	string find(string callsign);
	user_t findUser(string callsign);

private:
	string m_file_dmrid;
	string m_file_cc;

	unordered_map<string, string> m_table;
	unordered_map<string, string> m_cc;

	bool load();
	bool loadCountryCode();
	// bool loadUsers();
};

#endif
