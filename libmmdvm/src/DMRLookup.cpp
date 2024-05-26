/*
# Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
*/
#include "DMRLookup.hpp"
#include "Utils.hpp"
#include "DMRId.hpp"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>

using namespace std;
using namespace utils;

CDMRLookup::CDMRLookup(const string& filepath) :
m_file_dmrid(filepath + "/DMRIds.dat"),
m_file_cc(filepath + "/CountryCode.txt"),
m_table(),
m_cc()
{
	// this->read();
}

CDMRLookup::~CDMRLookup() {
	delete this;
}

bool CDMRLookup::read() {
	bool ret = load();
	ret = loadCountryCode();
	// bool ret = loadUsers();

	return ret;
}

string CDMRLookup::find(string callsign) {
	string line;
	try {
		line = m_table.at(callsign);
		
	} catch (...) {
		line = "";
	}

	return line;
}

user_t CDMRLookup::findUser(string callsign) {	
	user_t user;

	try {
		string line = find(callsign);
		if (line == "") {
			return user;
		}
		
		const char *buffer = line.c_str();
		char* s = strdup(buffer);
		char* p1 = ::strsep(&s, "\t");
		// char* p2 = ::strsep(&s, "\t");
		char* p3 = ::strsep(&s, "\t");

		if (p1 != NULL) {
			user.name = string(p1);
		}
		// if (p2 != NULL) {
		// 	user.city = string(p2);
		// }
		if (p3 != NULL) {
			user.country = m_cc.at(string(p3));
		}

	} catch (...) {

	}

	return user;
}

bool CDMRLookup::loadCountryCode() {
	FILE* fp = ::fopen(m_file_cc.c_str(), "rt");
	if (fp == NULL) {
		printf("Cannot open the CountryCode lookup file - %s\n", m_file_cc.c_str());
		return false;
	}

	m_cc.clear();

	char buffer[100U];

	while (::fgets(buffer, 100U, fp) != NULL) {
		if (buffer[0U] == '#')
			continue;

		char *s = buffer;
		char *p1 = ::strsep(&s, " \t");

		if (p1 != NULL) {
			string iso = string(p1);
			m_cc[iso] = rtrim(string(s));
			// cout << m_cc[iso] << endl;
		}
	}

	::fclose(fp);

	size_t size = m_cc.size();
	if (size == 0U)
		return false;

	return true;
}

bool CDMRLookup::load() {
	FILE* fp = ::fopen(m_file_dmrid.c_str(), "rt");
	if (fp == NULL) {
		printf("Cannot open the DMR Id lookup file - %s\n", m_file_dmrid.c_str());
		return false;
	}

	m_table.clear();

	char buffer[150U];

	while (::fgets(buffer, 150U, fp) != NULL) {
		if (buffer[0U] == '#')
			continue;

		// char *s = strdup(buffer);
		char *s = buffer;

		char* p1 = ::strsep(&s, " \t");
		char* p2 = ::strsep(&s, " \t");  // tokenize to eol to capture name as well

		if (p1 != NULL && p2 != NULL) {
			// unsigned int id = (unsigned int)::atoi(p1);
			
			string callsign = string(p2);
			m_table[callsign] = rtrim(string(s));

			// cout << m_table[callsign] << endl;
		}
	}

	::fclose(fp);

	size_t size = m_table.size();
	if (size == 0U)
		return false;

	// LogInfo("Loaded %u Ids to the DMR callsign lookup table", size);

	return true;
}



/*
bool CDMRLookup::loadUsers() {
	FILE* fp = ::fopen(m_filename.c_str(), "rt");
	if (fp == NULL) {
		printf("Cannot open the DMR Id lookup file - %s\n", m_filename.c_str());
		return false;
	}

	m_users.clear();

	char buffer[100U];

	while (::fgets(buffer, 100U, fp) != NULL) {
		if (buffer[0U] == '#')
			continue;

		user_t user;
		string callsign;
		char *s = strdup(buffer);
		char* p1 = ::strsep(&s, " \t");
		// char* p2 = ::strsep(&s, " \r\n");  // tokenize to eol to capture name as well
		char* p2 = ::strsep(&s, " \t");
		char* p3 = ::strsep(&s, "\t");
		char* p4 = ::strsep(&s, "\t");
		char* p5 = ::strsep(&s, "\t");

		if (p1 != NULL && p2 != NULL && p3 != NULL) {
			unsigned int id = (unsigned int)::atoi(p1);
			callsign = string(p2);
			
			// cout << callsign << endl;
			user.id = id;
			user.name = string(p3);
		}

		if (p4 != NULL) {
			user.city = string(p4);
		}

		if (p5 != NULL) {
			user.country = string(p5);
		}

		m_users[callsign] = user;
	}

	::fclose(fp);

	size_t size = m_users.size();
	if (size == 0U)
		return false;

	// LogInfo("Loaded %u Ids to the DMR callsign lookup table", size);
	return true;
}

*/