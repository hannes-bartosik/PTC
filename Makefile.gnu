$(info Got $$LIBS as follows [${LIBS}])

include ../../conf/make_root_config

$(info Got $$LIBS after make_root_config [${LIBS}])

$(info Got $$FC after make_root_config [${FC}])

#Fortran compiler
FC=gfortran

OBJDIR=obj

DIRS  = $(patsubst %/, %, $(filter %/, $(shell ls -F))))
SRCS  = $(wildcard *.cc)
SRCS += $(foreach dir, $(DIRS), $(patsubst $(dir)/%.cc, %.cc, $(wildcard $(dir)/*.cc)))

OBJS = $(patsubst %.cc, ./$(OBJDIR)/%.o, $(SRCS))

FORT_DIRS  = source interface
$(info a1 $(FORT_SRCS))
FORT_SRCS  = $(wildcard *.f90)
$(info a2 $(FORT_DIRS))

FORT_SRCS += $(foreach dir, $(FORT_DIRS), $(patsubst $(dir)/%.f90, %.f90, $(wildcard $(dir)/*.f90)))
$(info a3 $(FORT_SRCS))

FORT_OBJS = $(patsubst %.f90, ./$(OBJDIR)/%.o, $(FORT_SRCS))

# Include files can be anywhere, we use only two levels
UPPER_DIRS = $(filter-out test%, $(patsubst %/, %, $(filter %/, $(shell ls -F ../../src))))
LOWER_DIRS = $(foreach dir, $(UPPER_DIRS), $(patsubst %/, ../../src/$(dir)/%, $(filter %/, $(shell ls -F ../../src/$(dir)))))

INCLUDES_LOCAL = $(patsubst %, -I../../src/%, $(UPPER_DIRS))
INCLUDES_LOCAL += $(filter-out %obj, $(patsubst %, -I%, $(LOWER_DIRS)))
INCLUDES_LOCAL += $(patsubst %, -I./%, $(filter %/, $(shell ls -F ./)))
INCLUDES_LOCAL += -I./

INC  = $(wildcard *.hh)
INC += $(wildcard *.h)
INC += $(foreach dir, $(DIRS), $(wildcard ./$(dir)/*.hh))
INC += $(foreach dir, $(DIRS), $(wildcard ./$(dir)/*.h))

#-------------------------------------------------------------------------------
# External library locations
#-------------------------------------------------------------------------------



$(info $$PROD_DIR is [${PROD_DIR}])
$(info $$INTEL_TARGET_ARCH is [${INTEL_TARGET_ARCH}])
$(info $$ORBIT_ARCH is [${ORBIT_ARCH}])

ifeq ($(ORBIT_ARCH),Darwin)
    LINKFLAGS += -undefined dynamic_lookup
endif
    
    
ifeq ($(FC),ifort)
    ifeq ($(PROD_DIR),)
        $(info $$PROD_DIR is empty [${PROD_DIR}])
        $(error Please source compilervars.sh and export PROD_DIR INTEL_TARGET_ARCH)
    endif
  
  
    ifeq ($(ORBIT_ARCH),Darwin)
        LIBS += -L$(PROD_DIR)/lib
        $(info Darwin $$LIBS is [${LIBS}])
        
    else ifeq ($(ORBIT_ARCH),Linux)
            ifeq ($(INTEL_TARGET_ARCH),)
                 $(info $$INTEL_TARGET_ARCH is empty [${INTEL_TARGET_ARCH}])
                 $(error Please source compilervars.sh and export PROD_DIR INTEL_TARGET_ARCH)
            endif
    
            LIBS += -L$(PROD_DIR)/lib/$(INTEL_TARGET_ARCH) 
            $(info Linux $$LIBS is [${LIBS}])  
    endif
    
    LIBS += -lifcore -lsvml
    $(info b $$LIBS is [${LIBS}])
endif

ifeq ($(FC),gfortran)
    ifeq ($(ORBIT_ARCH),Darwin)
         LIBS +=-L/opt/local/lib/gcc8
         LINKFLAGS += -Wl,-no_compact_unwind -Wl,-no_pie
    else
         LIBS +=-L/usr/lib/gcc/x86_64-redhat-linux/4.4.4
    endif
    
    LIBS += -lgfortran
endif

FORTFLAGS += -J$(OBJDIR)

#-------------------------------------------------------------------------------
# External 'include' locations
#-------------------------------------------------------------------------------

INCLUDES +=

#-------------------------------------------------------------------------------
# Wrappers CC FLAGS
#-------------------------------------------------------------------------------

WRAPPER_FLAGS = -fno-strict-aliasing

#-------------------------------------------------------------------------------
# CXXFLAGS
#-------------------------------------------------------------------------------

CXXFLAGS += -fPIC

#-------------------------------------------------------------------------------
# Shared library flags
#-------------------------------------------------------------------------------

SHARED_LIB = -shared

#-------------------------------------------------------------------------------
# ptc-orbit shared library
#-------------------------------------------------------------------------------

ptc_orbit_lib = libptc_orbit.so

#-------------------------------------------------------------------------------
#========rules=========================
#-------------------------------------------------------------------------------

	
compile: makeobjdir $(OBJS_WRAP) $(FORT_OBJS) $(OBJS) $(INC)
	@echo "==============="
	$(info $(OBJS))
	echo "==============="
	$(info $(FORT_OBJS))
#	$(error exxx)
	$(CXX) -fPIC $(SHARED_LIB) $(LIBS) $(LINKFLAGS) -o ../../lib/$(ptc_orbit_lib) $(OBJS) $(FORT_OBJS)


makeobjdir:
	mkdir -p $(OBJDIR)

clean:
	rm -rf ./$(OBJDIR)/*.o
	rm -rf ./$(OBJDIR)/*.os
	rm -rf ../../lib/$(ptc_orbit_lib)
	rm -rf ./$(OBJDIR)/*.mod
	rm -rf ./source/*~

./$(OBJDIR)/wrap_%.o : wrap_%.cc $(INC)
	$(CXX) $(CXXFLAGS) $(WRAPPER_FLAGS) $(INCLUDES_LOCAL) $(INCLUDES) -c $< -o $@;

./$(OBJDIR)/wrap_%.o : ./*/wrap_%.cc $(INC)
	$(CXX) $(CXXFLAGS) $(WRAPPER_FLAGS) $(INCLUDES_LOCAL) $(INCLUDES) -c $< -o $@;

./$(OBJDIR)/%.o : %.cc $(INC)
	$(CXX) $(CXXFLAGS) $(INCLUDES_LOCAL) $(INCLUDES) -c $< -o $@;

./$(OBJDIR)/%.o : ./*/%.cc $(INC)
	$(CXX) $(CXXFLAGS) $(INCLUDES_LOCAL) $(INCLUDES) -c $< -o $@;

./$(OBJDIR)/%.o : ./source/%.f90
	$(FC) $(FORTFLAGS)  -c $< -o $@;

./$(OBJDIR)/%.o : ./interface/%.f90
	$(FC) $(FORTFLAGS) ./source -c $< -o $@;


FC_DIR=source

ifeq ($(FDEP),)

include dependencies.mk

endif


