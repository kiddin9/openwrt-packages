
INSTALL = install
PREFIX  = /usr/bin

lmotool: src/lmotool.o src/template_lmo.o
	$(CC) $(LDFLAGS) -o src/lmotool src/lmotool.o src/template_lmo.o
	
install:
	$(INSTALL) -m 755 src/lmotool $(PREFIX)

clean:
	$(RM) src/lmotool src/*.o
