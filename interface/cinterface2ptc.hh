
//-------------------------------------------------------------------
// C interface to the methods in ptcinterface.f90 and class PTC_Map
//-------------------------------------------------------------------

#ifndef PTC_C_INTERFACE_H
#define PTC_C_INTERFACE_H

//MPI Function Wrappers
#include "orbit_mpi.hh"
#include "wrap_mpi_comm.hh"

#include <cstdlib>
#include <cmath>

//ORBIT bunch
#include "Bunch.hh"

//pyORBIT utils
#include "CppPyWrapper.hh"

#include "ParticleMacroSize.hh"
#include "Bunch.hh"
#include "OrbitConst.hh"

using namespace std;

// Main method to initialize PTC

extern "C" void ptc_init_(const char* file_name, int length_of_name);

// Get initial twiss at entrance of the lattice

extern "C" void ptc_get_twiss_init_(double* betax,  double* betay,
                                    double* alphax, double* alphay,
                                    double* etax,   double* etapx,
                                    double* etay,   double* etapy,
                                    double* cox,    double* copx,
                                    double* coy,    double* copy);

// Get number of PTC ORBIT nodes, harmonic number,
//     length of the ring, and gamma transition

extern "C" void ptc_get_ini_params_(int* nNodes,   int* nHarm,
                                    double* lRing, double* gammaT);

// Get synchronous particle params mass, charge, and energy

extern "C" void ptc_get_syncpart_(double* mass, int* charge,
                                  double* kin_energy);

// Call ptc method to set up synchronous particle calualtions
//     (before and after node)
// This method should be called from PTC_Map instance
// These methods are located inside PTC (not interfaces)
// If node_index < 0 then PTC will do something inside
//     that does not relate to tracking

extern "C" void ptc_synchronous_set_(int* node_index);
extern "C" void ptc_synchronous_after_(int* node_index);

// Read the acceleration table into the ptc code

extern "C" void ptc_read_accel_table_(const char* file_name,
                                      int length_of_name);

// Get twiss and length for a node with index

extern "C" void ptc_get_twiss_for_node_(int* node_index, double* length,
                                        double* betax,   double* betay,
                                        double* alphax,  double* alphay,
                                        double* etax,    double* etapx,
                                        double* etay,    double* etapy,
                                        double* cox,    double* copx,
                                        double* coy,    double* copy);

// Track 6D coordinates through a PTC-ORBIT node

extern "C" void ptc_track_particle_(int* node_index,
                                    double* x,   double* xp,
                                    double* y,   double* yp,
                                    double* phi, double* dE);

// Reads additional ptc commands from file and executes them inside ptc

extern "C" void ptc_script_(const char* p_in_file, int length_of_name);

//===========================================================
// This method should be called before particle tracking.
//  It specifies the type of the task that will be performed
//  in ORBIT before particle tracking for particular node.
//  i_task = 0 - do not do anything
//  i_task = 1 - energy of the sync. particle changed
//===========================================================

extern "C" void ptc_get_task_type_(int* i_node, int* i_task);

//===================================================
// This returns the fundamental frequency of the RF cavities
// It will be used to transform phi to z[m]
//===================================================

extern "C" void  ptc_get_omega_(double* X);

//===================================================
// Method to track a bunch of particles using
// ptc_track_particle_
//===================================================

void ptc_trackBunch(Bunch* bunch, double ZtoPhi,
                    int &orbit_ptc_node_index);

//===================================================
// This returns the tunes
//===================================================

extern "C" void  ptc_get_tunes_(double* X, double* Y);


//===================================================
// This recalculates the PTC TWISS
//===================================================

extern "C" void  ptc_update_twiss_();


#endif  // PTC_C_INTERFACE_H
