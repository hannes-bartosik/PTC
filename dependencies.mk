# chain of dependencies (PTC from MAD-X)
obj/a_scratch_size.o:           $(FC_DIR)/a_scratch_size.f90
obj/b_da_arrays_all.o:          $(FC_DIR)/b_da_arrays_all.f90         obj/a_scratch_size.o
obj/cb_da_arrays_all.o:         $(FC_DIR)/cb_da_arrays_all.f90        obj/a_scratch_size.o
obj/c_dabnew.o:                 $(FC_DIR)/c_dabnew.f90                obj/b_da_arrays_all.o
#obj/d_lielib.o:                $(FC_DIR)/d_lielib.f90                obj/c_dabnew.o
obj/d_lielib.o:                 $(FC_DIR)/d_lielib.f90                $(if $(call eq,$(NTPSA),yes),obj/c_tpsa_interface.o,obj/c_dabnew.o)
obj/cc_dabnew.o:                $(FC_DIR)/cc_dabnew.f90               obj/cb_da_arrays_all.o
obj/h_definition.o:             $(FC_DIR)/h_definition.f90            obj/cc_dabnew.o obj/d_lielib.o
obj/i_tpsa.o:                   $(FC_DIR)/i_tpsa.f90                  obj/h_definition.o
obj/j_tpsalie.o:                $(FC_DIR)/j_tpsalie.f90               obj/i_tpsa.o
obj/k_tpsalie_analysis.o:       $(FC_DIR)/k_tpsalie_analysis.f90      obj/j_tpsalie.o
obj/l_complex_taylor.o:         $(FC_DIR)/l_complex_taylor.f90        obj/k_tpsalie_analysis.o
obj/m_real_polymorph.o:         $(FC_DIR)/m_real_polymorph.f90        obj/l_complex_taylor.o
obj/n_complex_polymorph.o:      $(FC_DIR)/n_complex_polymorph.f90     obj/m_real_polymorph.o
obj/o_tree_element.o:           $(FC_DIR)/o_tree_element.f90          obj/n_complex_polymorph.o

obj/Ci_tpsa.o:                  $(FC_DIR)/Ci_tpsa.f90                 obj/o_tree_element.o 

obj/Sa_extend_poly.o:           $(FC_DIR)/Sa_extend_poly.f90          obj/Ci_tpsa.o
obj/Sb_sagan_pol_arbitrary.o:   $(FC_DIR)/Sb_sagan_pol_arbitrary.f90  obj/Sa_extend_poly.o
obj/Sc_euclidean.o:             $(FC_DIR)/Sc_euclidean.f90            obj/Sb_sagan_pol_arbitrary.o
obj/Sd_frame.o:                 $(FC_DIR)/Sd_frame.f90                obj/Sc_euclidean.o
obj/Se_status.o:                $(FC_DIR)/Se_status.f90               obj/Sd_frame.o
obj/Sf_def_all_kinds.o:         $(FC_DIR)/Sf_def_all_kinds.f90        obj/Se_status.o
obj/Sg_sagan_wiggler.o:         $(FC_DIR)/Sg_sagan_wiggler.f90        obj/Sh_def_kind.o 
obj/Sh_def_kind.o:              $(FC_DIR)/Sh_def_kind.f90             obj/Sf_def_all_kinds.o
obj/Si_def_element.o:           $(FC_DIR)/Si_def_element.f90          obj/Sg_sagan_wiggler.o
obj/Sk_link_list.o:             $(FC_DIR)/Sk_link_list.f90            obj/Si_def_element.o
obj/Sl_family.o:                $(FC_DIR)/Sl_family.f90               obj/Sk_link_list.o
obj/Sm_tracking.o:              $(FC_DIR)/Sm_tracking.f90             obj/Sl_family.o
obj/Sma0_beam_beam_ptc.o:       $(FC_DIR)/Sma0_beam_beam_ptc.f90      obj/Sm_tracking.o
obj/Sma_multiparticle.o:        $(FC_DIR)/Sma_multiparticle.f90       obj/Sma0_beam_beam_ptc.o
obj/Sn_mad_like.o:              $(FC_DIR)/Sn_mad_like.f90             obj/Sma_multiparticle.o
obj/So_fitting.o:               $(FC_DIR)/So_fitting.f90              obj/Sn_mad_like.o
obj/Sp_keywords.o:              $(FC_DIR)/Sp_keywords.f90             obj/So_fitting.o
obj/Spb_fake_gino_sub.o:        $(FC_DIR)/Spb_fake_gino_sub.f90
obj/Sq_orbit_ptc.o:             $(FC_DIR)/Sq_orbit_ptc.f90            obj/Sp_keywords.o
obj/Sr_spin.o:                  $(FC_DIR)/Sr_spin.f90                 obj/Sq_orbit_ptc.o
obj/Sra_fitting.o:              $(FC_DIR)/Sra_fitting.f90             obj/Sr_spin.o
obj/St_pointers.o:              $(FC_DIR)/St_pointers.f90             obj/Sp_keywords.o obj/Ss_fake_mad.o 

obj/h_definition.o:             $(FC_DIR)/a_def_frame_patch_chart.inc $(FC_DIR)/a_def_all_kind.inc \
                                $(FC_DIR)/a_def_sagan.inc $(FC_DIR)/a_def_element_fibre_layout.inc
obj/Sf_def_all_kinds.o:         $(FC_DIR)/a_def_worm.inc
obj/Sp_keywords.o:              $(FC_DIR)/a_namelists.inc

# chain of dependencies (PTC lib)
obj/Ss_fake_mad.o:              $(FC_DIR)/Ss_fake_mad.f90                   obj/Sra_fitting.o
obj/ptcinterface.o:             interface/ptcinterface.f90                  obj/St_pointers.o
