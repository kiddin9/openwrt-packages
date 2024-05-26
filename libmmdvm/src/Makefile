#
# Copyright 2019-2020 Michael BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
#

# for lua 5.4
LUAVER = 5.4
LUAPATH = /usr/local/Cellar/lua/5.4.4_1/

# for lua 5.3
# LUAVER = 5.3
# LUAPATH = /usr/local/Cellar/lua/5.3.5_1

# for lua 5.1
# LUAVER = 5.1
# LUAPATH = /usr/local/Cellar/lua\@5.1/5.1.5_8

CXXFLAGS = -g -O3 -Wall -std=c++0x -I$(LUAPATH)/include/lua$(LUAVER)
LDFLAGS = -lm -L$(LUAPATH)/lib -bundle -undefined dynamic_lookup

# CXXFLAGS = -g -O3 -Wall -std=c++0x
# LDFLAGS = -llua -lm -shared

FPIC = -fPIC
OBJ = DMRLookup.o DMRId.o Utils.o
LIB = mmdvm.so

%.o: %.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(FPIC) -c -o $@ $<

compile: $(OBJ)
	$(CXX) $(LDFLAGS) -o $(LIB) $(OBJ)
	# $(CXX) -lm -L$(LUAPATH)/lib -o test $(OBJ)


install: compile
	mkdir -p $(DESTDIR)/usr/lib/lua
	cp $(LIB) $(DESTDIR)/usr/lib/lua/$(LIB)

clean:
	rm -f *.o *.so
