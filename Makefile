
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

G13D_HOME = /usr/lib/g13d

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

install:
	@echo "using $(BUILDDIR) for assembling the install"
	@rm -rf $(BUILDDIR)/*
	@mkdir -p $(BUILDDIR)/etc
	@cp configs/*.bind $(BUILDDIR)/etc/
	
	@echo "gathering the binaries..."
	@cp $(TARGETDIR)/* $(BUILDDIR)/
	
	@echo "gathering the apps..."
	@mkdir -p $(BUILDDIR)/apps
	@cp apps/* $(BUILDDIR)/apps/
	
	@echo "gathering the init scripts..."
	@cp scripts/* $(BUILDDIR)/
	
	@echo "creating install home directory..."
	@mkdir -p "$(G13D_HOME)"
	
	@echo "installing scripts and bindings to $(G13D_HOME) ..."
	@cp -r $(BUILDDIR)/* "$(G13D_HOME)/" && chmod a+x "$(G13D_HOME)"/g13d*
	
	@echo "creating symlinks for executables in /usr/bin and /etc/init.d"
	
	@echo "create symlinks for g13d-run in /usr/bin ..."
	@ln -s "$(G13D_HOME)/g13d-run" /usr/bin/g13d-run
	@mkdir "/tmp/g13d" && chmod -R a+rwx "/tmp/g13d"
		
	@echo "create symlinks for g13d-service in /etc/init.d ..."
	@ln -s "$(G13D_HOME)/g13d-service" /etc/init.d/g13d-service
	
	@echo "create symlink for g13d config dir in /etc/g13d ..."
	@ln -s "$(G13D_HOME)/etc" /etc/g13d.d
	
	@echo "systemd service setup ..."
	@ln -s  "$(G13D_HOME)/g13d-service.service" /lib/systemd/g13d-service.service
	@systemctl daemon-reload
	@systemctl enable g13d-service.service
	
	@echo "done."

uninstall:
	rm /usr/bin/g13d-run
	rm /etc/g13d.d
	rm /etc/init.d/g13d-service
	rm /lib/systemd/g13d-service.service
	rm -rf /usr/lib/g13d/
	rm -rf /tmp/g13d
	systemctl daemon-reload

