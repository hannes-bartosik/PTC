#include "Python.h"
#include "orbit_mpi.hh"

#include "pyORBIT_Object.hh"

#include "cinterface2ptc.hh"

#include "wrap_cinterface2ptc.hh"
#include "wrap_matrix_generator.hh"
#include "wrap_bunch.hh"

using namespace OrbitUtils;

namespace wrap_ptc
{
  void error(const char* msg){ ORBIT_MPI_Finalize(msg); }

#ifdef __cplusplus
extern "C"
{
#endif

//---------------------------------------------------------
// ptc method wrappers
//---------------------------------------------------------

// Main routine to initialize PTC.

static PyObject* wrap_ptc_init_(PyObject *self, PyObject *args)
{
  const char* file_name;
  int length_of_name;
  if(!PyArg_ParseTuple(args, "si:_ptc_init_",
                       &file_name, &length_of_name))
  {
    error("ptc_init_ - cannot parse arguments!");
  }

  cout << "file_name = " << file_name << " Length =" << length_of_name << "\n";

  ptc_init_(file_name, length_of_name);
  Py_INCREF(Py_None);
  return Py_None;
}

// Get initial twiss at entrance of the lattice.

static PyObject* wrap_ptc_get_twiss_init_(PyObject *self, PyObject *args)
{
  double betax;
  double betay;
  double alphax;
  double alphay;
  double etax;
  double etapx;
  double etay;
  double etapy;
  double cox;
  double copx;
  double coy;
  double copy;
  ptc_get_twiss_init_(&betax, &betay, &alphax, &alphay, &etax, &etapx, &etay, &etapy, &cox, &copx, &coy, &copy);
  return Py_BuildValue("(dddddddddddd)", betax, betay, alphax, alphay, etax, etapx, etay, etapy, cox, copx, coy, copy);
}

// Get number of PTC ORBIT nodes, harmonic number,
// length of the ring, and gamma transition.

static PyObject* wrap_ptc_get_ini_params_(PyObject *self, PyObject *args)
{
  int nNodes;
  int nHarm;
  double lRing;
  double gammaT;
  ptc_get_ini_params_(&nNodes, &nHarm, &lRing, &gammaT);
  return Py_BuildValue("(iidd)", nNodes, nHarm, lRing, gammaT);
}

// Get synchronous particle params mass, charge, and energy.

static PyObject* wrap_ptc_get_syncpart_(PyObject *self, PyObject *args)
{
  double mass;
  int charge;
  double kin_energy;
  ptc_get_syncpart_(&mass, &charge, &kin_energy);
  return Py_BuildValue("(did)", mass, charge, kin_energy);
}


static PyObject* wrap_ptc_synchronous_after_(PyObject *self, PyObject *args)
{
  int* node_index;
  if(!PyArg_ParseTuple(args, "i:ptc_synchronous_after_",
                       &node_index))
  {
    error("ptc_synchronous_after_ - cannot parse arguments!");
  }
  ptc_synchronous_after_(node_index);
  Py_INCREF(Py_None);
  return Py_None;
}

// Read the acceleration table into the ptc code.

static PyObject* wrap_ptc_read_accel_table_(PyObject *self, PyObject *args)
{
  const char* file_name;
  int length_of_name;
  if(!PyArg_ParseTuple(args, "si:ptc_read_accel_table_",
                       &file_name, &length_of_name))
  {
    error("ptc_read_accel_table_ - cannot parse arguments!");
  }
  ptc_read_accel_table_(file_name, length_of_name);
  Py_INCREF(Py_None);
  return Py_None;
}

// Get twiss and length for a node with index.

static PyObject* wrap_ptc_get_twiss_for_node_(PyObject *self, PyObject *args)
{
  int node_index;
  double length;
  double betax;
  double betay;
  double alphax;
  double alphay;
  double etax;
  double etapx;
  double etay;
  double etapy;
  double cox;
  double copx;
  double coy;
  double copy;
  if(!PyArg_ParseTuple(args, "i:ptc_get_twiss_for_node_",
                       &node_index))
  {
    error("ptc_get_twiss_for_node_ - cannot parse arguments!");
  }
  ptc_get_twiss_for_node_(&node_index, &length, &betax, &betay,
                          &alphax, &alphay, &etax, &etapx, &etay, &etapy, &cox, &copx, &coy, &copy);
  return Py_BuildValue("(ddddddddddddd)", length,
                       betax, betay, alphax, alphay, etax, etapx, etay, etapy, cox, copx, coy, copy);
}

// Track 6D coordinates through a PTC-ORBIT node.

static PyObject* wrap_ptc_track_particle_(PyObject *self, PyObject *args)
{
  int* node_index;
  double* x;
  double* xp;
  double* y;
  double* yp;
  double* phi;
  double* dE;
  if(!PyArg_ParseTuple(args, "idddddd:ptc_track_particle_",
                       &node_index, &x, &xp, &y, &yp, &phi, &dE))
  {
    error("ptc_track_particle_ - cannot parse arguments!");
  }
  ptc_track_particle_(node_index, x, xp, y, yp, phi, dE);
  Py_INCREF(Py_None);
  return Py_None;
}

// Reads additional ptc commands from file and executes them inside ptc.

static PyObject* wrap_ptc_script_(PyObject *self, PyObject *args)
{
  const char* p_in_file;
  int length_of_name;
  if(!PyArg_ParseTuple(args, "si:ptc_script_",
                       &p_in_file, &length_of_name))
  {
    error("ptc_script_ - cannot parse arguments!");
  }
  ptc_script_(p_in_file, length_of_name);
  Py_INCREF(Py_None);
  return Py_None;
}

//===========================================================
// This method should be called before particle tracking.
// It specifies the type of the task that will be performed
// in ORBIT before particle tracking for particular node.
//   i_task = 0 - do not do anything
//   i_task = 1 - energy of the sync. particle changed
//===========================================================

static PyObject* wrap_ptc_get_task_type_(PyObject *self, PyObject *args)
{
  int* i_node;
  int* i_task;
  if(!PyArg_ParseTuple(args, "ii:ptc_get_task_type_",
                       &i_node, &i_task))
  {
    error("ptc_get_task_type_ - cannot parse arguments!");
  }
  ptc_get_task_type_(i_node, i_task);
  Py_INCREF(Py_None);
  return Py_None;
}

//===================================================
// This returns the lowest frequency of the RF cavities.
// It will be used to transform phi to z[m].
//===================================================

static PyObject* wrap_ptc_get_omega_(PyObject *self, PyObject *args)
{
  double* X;
  if(!PyArg_ParseTuple(args, "d:ptc_get_omega_",
                       &X))
  {
    error("ptc_get_omega_ - cannot parse arguments!");
  }
  ptc_get_omega_(X);
  Py_INCREF(Py_None);
  return Py_None;
}

//===================================================
// trackBunch tracks a bunch of particles using
// ptc_track_particle_.
//===================================================

static PyObject* wrap_ptc_trackBunch(PyObject *self, PyObject *args)
{
  PyObject* pyBunch;
  double PhaseLength;
  int orbit_ptc_node_index;
  if(!PyArg_ParseTuple(args, "Odi:ptc_trackBunch", &pyBunch,
                       &PhaseLength, &orbit_ptc_node_index))
  {
    error("ptc_trackBunch(Bunch* bunch, double PhaseLength, const int &orbit_ptc_node_index) - parameter is needed.");
  }
  PyObject* pyORBIT_Bunch_Type = wrap_orbit_bunch::getBunchType("Bunch");
  if(!PyObject_IsInstance(pyBunch, pyORBIT_Bunch_Type))
  {
    error("ptc_trackBunch(Bunch* bunch, double PhaseLength, const int &orbit_ptc_node_index) - the first parameter should be a Bunch.");
  }
  Bunch* cpp_bunch = (Bunch*) ((pyORBIT_Object*) pyBunch)->cpp_obj;
  ptc_trackBunch(cpp_bunch, PhaseLength, orbit_ptc_node_index);
  Py_INCREF(Py_None);
  return Py_None;
}


static PyObject* wrap_ptc_set_dbglevel_(PyObject *self, PyObject *args)
{
  int dbglevel;
  if(!PyArg_ParseTuple(args, "i:ptc_set_dbglevel_",
                       &dbglevel))
  {
    error("ptc_set_dbglevel_ - cannot parse arguments!");
  }
  
  setdebuglevel_(&dbglevel);
  
  Py_INCREF(Py_None);
  return Py_None;
}


static PyMethodDef ptcMethods[] =
{
  {"ptc_init_",               wrap_ptc_init_,               METH_VARARGS, "Initializes PTC"},
  {"ptc_get_twiss_init_",     wrap_ptc_get_twiss_init_,     METH_VARARGS, "Gets entrance twiss parameters"},
  {"ptc_get_ini_params_",     wrap_ptc_get_ini_params_,     METH_VARARGS, "Gets main lattice parameters"},
  {"ptc_get_syncpart_",       wrap_ptc_get_syncpart_,       METH_VARARGS, "Gets synchronous particle parameters"},
  {"ptc_synchronous_after_",  wrap_ptc_synchronous_after_,  METH_VARARGS, "Completes synchronous particle calculations"},
  {"ptc_read_accel_table_",   wrap_ptc_read_accel_table_,   METH_VARARGS, "Reads acceleration information table"},
  {"ptc_get_twiss_for_node_", wrap_ptc_get_twiss_for_node_, METH_VARARGS, "Twiss parameters at node"},
  {"ptc_track_particle_",     wrap_ptc_track_particle_,     METH_VARARGS, "Tracks particle through PTC element"},
  {"ptc_script_",             wrap_ptc_script_,             METH_VARARGS, "Additional ptc commands"},
  {"ptc_get_task_type_",      wrap_ptc_get_task_type_,      METH_VARARGS, "Call before tracking"},
  {"ptc_get_omega_",          wrap_ptc_get_omega_,          METH_VARARGS, "Returns fundamental RF frequency"},
  {"ptc_trackBunch",          wrap_ptc_trackBunch,          METH_VARARGS, "Track the Bunch through a PTC element"},
  {"ptc_setdbglevel",         wrap_ptc_set_dbglevel_,       METH_VARARGS, "Set debug level in PTC-Orbit interface"},
  {NULL, NULL}
};

//--------------------------------------------------
// Initialization of ptc routines.
//--------------------------------------------------

void initlibptc_orbit(void)
{
  PyObject *m, *d;
  m = Py_InitModule((char*)"libptc_orbit", ptcMethods);
  d = PyModule_GetDict(m);
}

PyObject* getBasePTCType(char* name)
{
  PyObject* mod = PyImport_ImportModule("ptc");
  PyObject* pyType = PyObject_GetAttrString(mod, name);
  Py_DECREF(mod);
  Py_DECREF(pyType);
  return pyType;
}


#ifdef __cplusplus
}
#endif

} //end of namespace wrap_ptc
