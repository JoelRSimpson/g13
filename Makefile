
CC = g++ # This is the main compiler
# CC := clang --analyze # and comment out the linker last line for sanity
SRCDIR = src
BUILDDIR = build
TARGETDIR = bin
TARGET = $(TARGETDIR)/g13d

SOURCES = $(shell find $(SRCDIR) -type f -name *.cc)
OBJECTS = $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.cc=.o))
CFLAGS = $(CXXFLAGS) -DBOOST_LOG_DYN_LINK -std=c++0x
LIB = -lusb-1.0 -lboost_program_options -lboost_log -lboost_system -lpthread
INC = -I include

all: bin/g13d bin/pbm2lpbm

$(TARGET): $(OBJECTS)
	@echo " Linking..."
	@echo " $(CC) $^ -o $(TARGET) $(LIB)"; $(CC) $^ -o $(TARGET) $(LIB)

$(BUILDDIR)/%.o: $(SRCDIR)/%.cc
	@mkdir -p $(BUILDDIR)
	@echo " $(CC) $(CFLAGS) $(INC) -c -o $@ $<"; $(CC) $(CFLAGS) $(INC) -c -o $@ $<
	
bin/pbm2lpbm: $(SRCDIR)/pbm2lpbm.c
	g++ -o bin/pbm2lpbm $(SRCDIR)/pbm2lpbm.c

clean:
	@echo " Cleaning..."; 
	@echo " $(RM) -r $(BUILDDIR) $(TARGETDIR)/g13d $(TARGETDIR)/pbm2lpbm"; $(RM) -r $(BUILDDIR) $(TARGETDIR)/g13d $(TARGETDIR)/pbm2lpbm

.PHONY: all
	
.PHONY: clean

package:
	rm -Rf g13-userspace
	mkdir g13-userspace
	cp g13.cc g13.h logo.h Makefile pbm2lpbm.c g13-userspace
	tar cjf g13-userspace.tbz2 g13-userspace
	rm -Rf g13-userspace
