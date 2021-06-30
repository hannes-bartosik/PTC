#include <cstdlib>

#include "cinterface2ptc.hh"

#include "ParticleMacroSize.hh"
#include "Bunch.hh"
#include "OrbitConst.hh"

using namespace OrbitUtils;

void ptc_trackBunch(Bunch* bunch, double PhaseLength,
                    int &orbit_ptc_node_index)
{
  double x_map;
  double xp_map;
  double y_map;
  double yp_map;
  double ct_map;
  double pt_map;
  double Ekin;

  double beta0_ent, p0c_ent, beta0_ext, p0c_ext;
  //ptc_synchronous_set_(&orbit_ptc_node_index); function does nothing now so it was removed from ptc interface

  bunch->compress();
  SyncPart* syncPart = bunch->getSyncPart();
  double** arr = bunch->coordArr();
  
  for(int i = 0; i < bunch->getSize(); i++)
  {
    if(i==0)
    {
      ptc_get_p0c_(&p0c_ent);
      ptc_get_beta0_(&beta0_ent);
    }
    x_map   =  arr[i][0];
    xp_map  =  arr[i][1];
    y_map   =  arr[i][2];
    yp_map  =  arr[i][3];
    ct_map  = -arr[i][4]/beta0_ent;
    pt_map  =  arr[i][5]/p0c_ent;

    ptc_track_particle_(&orbit_ptc_node_index, &x_map, &xp_map,
                        &y_map, &yp_map, &pt_map, &ct_map);

    if(i==0)
    {
      ptc_get_p0c_(&p0c_ext);
      ptc_get_beta0_(&beta0_ext);
    }
    arr[i][0] =  x_map;
    arr[i][1] =  xp_map;
    arr[i][2] =  y_map;
    arr[i][3] =  yp_map;
    arr[i][4] = -ct_map*beta0_ext;
    arr[i][5] =  pt_map*p0c_ext;
  }
  
  ptc_synchronous_after_(&orbit_ptc_node_index);

  if(p0c_ent != p0c_ext)
  {
    ptc_get_kinetic_(&Ekin);
    syncPart->setMomentum(syncPart->energyToMomentum(Ekin));
  }

}

