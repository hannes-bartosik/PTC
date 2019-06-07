$(info Got $$LIBS as follows [${LIBS}])

include ../../conf/make_root_config

$(info Got $$LIBS after make_root_config [${LIBS}])

#Fortran compiler
FC=ifort


DIRS  = $(patsubst %/, %, $(filter %/, $(shell ls -F))))
SRCS  = $(wildcard *.cc)
SRCS += $(foreach dir, $(DIRS), $(patsubst $(dir)/%.cc, %.cc, $(wildcard $(dir)/*.cc)))

OBJS = $(patsubst %.cc, ./obj/%.o, $(SRCS))

FORT_DIRS  = source interface
FORT_SRCS  = $(wildcard *.f90)
FORT_SRCS += $(foreach dir, $(FORT_DIRS), $(patsubst $(dir)/%.f90, %.f90, $(wildcard $(dir)/*.f90)))

FORT_OBJS = $(patsubst %.f90, ./obj/%.o, $(FORT_SRCS))

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

ifeq ($(FC),ifort)
    ifeq ($(PROD_DIR),)
        $(info $$PROD_DIR is empty [${PROD_DIR}])
        $(error Please source compilervars.sh and export PROD_DIR INTEL_TARGET_ARCH)
    endif
  
  
    ifeq ($(ORBIT_ARCH),Darwin)
	LIBS += -L$(PROD_DIR)/lib
        $(info Darwin $$LIBS is [${LIBS}])
	LINKFLAGS += -undefined dynamic_lookup
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
  LIBS += -L/usr/lib/gcc/x86_64-redhat-linux/4.4.4 -lgfortran
endif

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
	$(CXX) -fPIC $(SHARED_LIB) $(LIBS) $(LINKFLAGS) -o ../../lib/$(ptc_orbit_lib) $(OBJS) $(FORT_OBJS)

makeobjdir:
	mkdir -p obj

clean:
	rm -rf ./obj/*.o
	rm -rf ./obj/*.os
	rm -rf ../../lib/$(ptc_orbit_lib)
	rm -rf ./*.mod
	rm -rf ./source/*~

./obj/wrap_%.o : wrap_%.cc $(INC)
	$(CXX) $(CXXFLAGS) $(WRAPPER_FLAGS) $(INCLUDES_LOCAL) $(INCLUDES) -c $< -o $@;

./obj/wrap_%.o : ./*/wrap_%.cc $(INC)
	$(CXX) $(CXXFLAGS) $(WRAPPER_FLAGS) $(INCLUDES_LOCAL) $(INCLUDES) -c $< -o $@;

./obj/%.o : %.cc $(INC)
	$(CXX) $(CXXFLAGS) $(INCLUDES_LOCAL) $(INCLUDES) -c $< -o $@;

./obj/%.o : ./*/%.cc $(INC)
	$(CXX) $(CXXFLAGS) $(INCLUDES_LOCAL) $(INCLUDES) -c $< -o $@;

./obj/%.o : ./source/%.f90
	$(FC) $(FORTFLAGS) -c $< -o $@;

./obj/%.o : ./interface/%.f90
	$(FC) $(FORTFLAGS) -I ./source -c $< -o $@;

obj/b_da_arrays_all.o: obj/a_scratch_size.o
obj/c_dabnew.o: obj/b_da_arrays_all.o
obj/d_lielib.o: obj/c_dabnew.o
obj/h_definition.o: obj/d_lielib.o
obj/i_tpsa.o: obj/h_definition.o
obj/j_tpsalie.o: obj/i_tpsa.o
obj/k_tpsalie_analysis.o: obj/j_tpsalie.o
obj/l_complex_taylor.o: obj/k_tpsalie_analysis.o
obj/m_real_polymorph.o: obj/l_complex_taylor.o
obj/n_complex_polymorph.o: obj/m_real_polymorph.o
obj/o_tree_element.o: obj/n_complex_polymorph.o
obj/Sa_extend_poly.o: obj/o_tree_element.o
obj/Sb_sagan_pol_arbitrary.o: obj/Sa_extend_poly.o
obj/Sc_euclidean.o: obj/Sb_sagan_pol_arbitrary.o
obj/Sd_frame.o: obj/Sc_euclidean.o
obj/Se_status.o: obj/Sd_frame.o
obj/Sf_def_all_kinds.o: obj/Se_status.o
obj/Sg_sagan_wiggler.o: obj/Sf_def_all_kinds.o
obj/Sh_def_kind.o: obj/Sg_sagan_wiggler.o
obj/Si_def_element.o: obj/Sh_def_kind.o
obj/Sk_link_list.o: obj/Si_def_element.o
obj/Sl_family.o: obj/Sk_link_list.o
obj/Sm_tracking.o: obj/Sl_family.o
obj/Sma0_beam_beam_ptc.o: obj/Sm_tracking.o
obj/Sma_multiparticle.o: obj/Sma0_beam_beam_ptc.o
obj/Sn_mad_like.o: obj/Sma_multiparticle.o
obj/So_fitting.o: obj/Sn_mad_like.o
obj/Sp_keywords.o: obj/So_fitting.o
obj/Sq_orbit_ptc.o: obj/Sp_keywords.o
obj/Sr_spin.o: obj/Sq_orbit_ptc.o
obj/Sra_fitting.o: obj/Sr_spin.o
obj/Ss_fake_mad.o: obj/Sra_fitting.o
obj/St_pointers.o: obj/Ss_fake_mad.o
obj/ptcinterface.o: obj/St_pointers.o
