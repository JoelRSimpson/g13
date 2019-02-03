CC = g++ # This is the main compiler
# CC := clang --analyze # and comment out the linker last line for sanity
SRCDIR = src
BUILDDIR = build
TARGETDIR = bin
TARGET = $(TARGETDIR)/g13d

SOURCES = $(shell find $(SRCDIR) -maxdepth 1 -type f -name *.cc)
#SOURCES = $(shell find $(SRCDIR) -maxdepth 1 -type f \( -name *.cc -not -name pbm2lpbm.cc \) )
OBJECTS = $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.cc=.o))
CFLAGS = $(CXXFLAGS) -DBOOST_LOG_DYN_LINK -std=c++0x
LIB = -lusb-1.0 -lboost_program_options -lboost_log -lboost_system -lpthread
INC = -I include

TMPDIR = tmp
G13D_HOME = /usr/lib/g13d

all: bin/g13d bin/pbm2lpbm

$(TARGET): $(OBJECTS)
	@echo " Linking..."
	@echo " $(CC) $^ -o $(TARGET) $(LIB)"; $(CC) $^ -o $(TARGET) $(LIB)

$(BUILDDIR)/%.o: $(SRCDIR)/%.cc
	@mkdir -p $(BUILDDIR)
	@echo " $(CC) $(CFLAGS) $(INC) -c -o $@ $<"; $(CC) $(CFLAGS) $(INC) -c -o $@ $<
	
bin/pbm2lpbm: $(SRCDIR)/pbm2lpbm/pbm2lpbm.cc
	g++ -o bin/pbm2lpbm $(SRCDIR)/pbm2lpbm/pbm2lpbm.cc

clean:
	@echo " Cleaning..."; 
	@echo " $(RM) -r $(BUILDDIR) $(TARGETDIR)/g13d $(TARGETDIR)/pbm2lpbm"; $(RM) -r $(BUILDDIR) $(TARGETDIR)/g13d $(TARGETDIR)/pbm2lpbm

.PHONY: all
	
.PHONY: clean

install:
	@echo "using $(TMPDIR) for assembling the install"
	@if [ -d $(TMPDIR) ]; then rm -rf $(TMPDIR); fi
	@mkdir -p $(TMPDIR)/etc
	@cp configs/*.bind $(TMPDIR)/etc/
	
	@echo "gathering the binaries..."
	@cp $(TARGETDIR)/* $(TMPDIR)/
	
	@echo "gathering the apps..."
	@mkdir -p $(TMPDIR)/apps
	@cp apps/* $(TMPDIR)/apps/
	
	@echo "gathering the init scripts..."
	@mkdir -p $(TMPDIR)/scripts
	@cp scripts/* $(TMPDIR)/scripts/
	
	@echo "creating install home directory..."
	@mkdir -p "$(G13D_HOME)"
	
	@echo "installing scripts and bindings to $(G13D_HOME) ..."
	@cp -r $(TMPDIR)/* "$(G13D_HOME)/" && chmod a+x "$(G13D_HOME)"/g13d* && chmod a+x "$(G13D_HOME)"/scripts/*
	
	@echo "creating symlinks for executables in /usr/bin and /etc/init.d"
	
	@echo "create symlinks for g13d-run in /usr/bin ..."
	@ln -s "$(G13D_HOME)/scripts/g13d-run" /usr/bin/g13d-run
	@mkdir "/tmp/g13d" && chmod -R a+rwx "/tmp/g13d"
		
	@echo "create symlinks for g13d service in /etc/init.d ..."
	@ln -s "$(G13D_HOME)/scripts/g13d" /etc/init.d/g13d
	
	@echo "create symlink for g13d config dir in /etc/g13d ..."
	@ln -s "$(G13D_HOME)/etc" /etc/g13d.d
	
	@echo "systemd service setup ..."
	@ln -s  "$(G13D_HOME)/scripts/g13d.service" /lib/systemd/g13d.service
	@systemctl daemon-reload
	@systemctl enable g13d.service
	
	@echo "starting service ..."
	@service g13d restart
	
	@echo "done."

uninstall:
	rm -f /usr/bin/g13d-run
	rm -f /etc/g13d.d
	rm -f /etc/init.d/g13d
	rm -f /lib/systemd/g13d.service
	rm -rf /usr/lib/g13d/
	rm -rf /tmp/g13d
	systemctl daemon-reload

