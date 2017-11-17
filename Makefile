
CC = g++ # This is the main compiler
# CC := clang --analyze # and comment out the linker last line for sanity
SRCDIR = src
BUILDDIR = build
TARGETDIR = bin
TARGET = $(TARGETDIR)/g13d
 
SRCEXT = cc
SOURCES = $(shell find $(SRCDIR) -type f -name *.$(SRCEXT))
OBJECTS = $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.$(SRCEXT)=.o))
CFLAGS = $(CXXFLAGS) -DBOOST_LOG_DYN_LINK -std=c++0x
LIB = -lusb-1.0 -lboost_program_options -lboost_log -lboost_system -lpthread
INC = -I include

all: bin/g13d bin/pbm2lpbm

$(TARGET): $(OBJECTS)
	@echo " Linking..."
	@echo " $(CC) $^ -o $(TARGET) $(LIB)"; $(CC) $^ -o $(TARGET) $(LIB)

$(BUILDDIR)/%.o: $(SRCDIR)/%.$(SRCEXT)
	@mkdir -p $(BUILDDIR)
	@echo " $(CC) $(CFLAGS) $(INC) -c -o $@ $<"; $(CC) $(CFLAGS) $(INC) -c -o $@ $<
	
bin/pbm2lpbm: $(SRCDIR)/pbm2lpbm.c
	g++ -o bin/pbm2lpbm $(SRCDIR)/pbm2lpbm.c

clean:
	@echo " Cleaning..."; 
	@echo " $(RM) -r $(BUILDDIR) $(TARGETDIR)/g13d $(TARGETDIR)/pbm2lpbm"; $(RM) -r $(BUILDDIR) $(TARGETDIR)/g13d $(TARGETDIR)/pbm2lpbm

.PHONY: all
	
.PHONY: clean

#all: g13d pbm2lpbm
#
#FLAGS=$(CXXFLAGS) -DBOOST_LOG_DYN_LINK -std=c++0x
#LIBS=-lusb-1.0 -lboost_log -lboost_log_setup-mt -lboost_thread -lboost_system-mt -lpthread
#
#g13.o: g13.h helper.hpp g13.cc
#	g++ $(FLAGS) -c g13.cc
#
#g13_main.o: g13.h helper.hpp g13_main.cc
#	g++ $(FLAGS) -c g13_main.cc
#
#
#g13_log.o: g13.h helper.hpp g13_log.cc
#	g++ $(FLAGS) -c g13_log.cc
#
#g13_fonts.o: g13.h helper.hpp g13_fonts.cc
#	g++ $(FLAGS) -c g13_fonts.cc
#
#g13_lcd.o: g13.h helper.hpp g13_lcd.cc
#	g++ $(FLAGS) -c g13_lcd.cc
#
#g13_stick.o: g13.h helper.hpp g13_stick.cc
#	g++ $(FLAGS) -c g13_stick.cc
#	
#g13_keys.o: g13.h helper.hpp g13_keys.cc
#	g++ $(FLAGS) -c g13_keys.cc
#
#helper.o: helper.hpp helper.cpp
#	g++ $(FLAGS) -c helper.cpp
#	
#	
#g13d: g13_main.o g13.o g13_log.o g13_fonts.o g13_lcd.o g13_stick.o g13_keys.o helper.o
#	g++ -o g13d -std=c++0x \
#		g13_main.o g13.o g13_log.o g13_fonts.o g13_lcd.o g13_stick.o g13_keys.o helper.o \
#	 	-lusb-1.0 -lboost_program_options \
#	 	-lboost_log    \
#	 	-lboost_system -lpthread
#
#pbm2lpbm: pbm2lpbm.c
#	g++ -o pbm2lpbm pbm2lpbm.c
#
#package:
#	rm -Rf g13-userspace
#	mkdir g13-userspace
#	cp g13.cc g13.h logo.h Makefile pbm2lpbm.c g13-userspace
#	tar cjf g13-userspace.tbz2 g13-userspace
#	rm -Rf g13-userspace
#clean: 
#	rm -f g13d pbm2lpbm