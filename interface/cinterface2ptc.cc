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
  double phi_map;
  double deltaE_map;

  double twopi = 2.0 * OrbitConst::PI;
  double ZtoPhi = -twopi / PhaseLength;
  double PhaseWrap = 0.0;

  //ptc_synchronous_set_(&orbit_ptc_node_index); function does nothing now so it was removed from ptc interface

  bunch->compress();
  SyncPart* syncPart = bunch->getSyncPart();
  double** arr = bunch->coordArr();

  for(int i = 0; i < bunch->getSize(); i++)
  {
    x_map   = 1000.0 * arr[i][0];
    xp_map  = 1000.0 * arr[i][1];
    y_map   = 1000.0 * arr[i][2];
    yp_map  = 1000.0 * arr[i][3];

    phi_map = ZtoPhi * arr[i][4];

    PhaseWrap = 0.0;
    if(phi_map < -OrbitConst::PI)
    {
      PhaseWrap = twopi;
    }
    if(phi_map >  OrbitConst::PI)
    {
      PhaseWrap = -twopi;
    }
    phi_map += PhaseWrap;

    deltaE_map = arr[i][5];

    ptc_track_particle_(&orbit_ptc_node_index, &x_map, &xp_map,
                        &y_map, &yp_map, &phi_map, &deltaE_map);

    arr[i][0] =  x_map / 1000.0;
    arr[i][1] =  xp_map / 1000.0;
    arr[i][2] =  y_map / 1000.0;
    arr[i][3] =  yp_map / 1000.0;
    arr[i][4] = (phi_map - PhaseWrap) / ZtoPhi;
    arr[i][5] = deltaE_map;
  }

  ptc_synchronous_after_(&orbit_ptc_node_index);
}
