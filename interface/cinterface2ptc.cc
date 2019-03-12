#include <cstdlib>

#include "cinterface2ptc.hh"

#include "ParticleMacroSize.hh"
#include "Bunch.hh"
#include "OrbitConst.hh"

using namespace OrbitUtils;

void ptc_trackBunch(Bunch* bunch, double PhaseLength,
                    int &orbit_ptc_node_index)
{
  double ct_map;
  double pt_map;

  ptc_synchronous_set_(&orbit_ptc_node_index);

  bunch->compress();
  SyncPart* syncPart = bunch->getSyncPart();
  double p0c = syncPart->getMomentum();
  double beta = syncPart->getBeta();
  double** arr = bunch->coordArr();
  

  for(int i = 0; i < bunch->getSize(); i++)
  {

    ct_map = - arr[i][4] / beta; 
    pt_map = arr[i][5] / p0c; 
  
    ptc_track_particle_(&orbit_ptc_node_index, &arr[i][0], &arr[i][1],
                        &arr[i][2], &arr[i][3], &pt_map, &ct_map); 
                        
    arr[i][4] =  - ct_map * beta;
    arr[i][5] =  pt_map * p0c;  
    
  }

  ptc_synchronous_after_(&orbit_ptc_node_index);
}
