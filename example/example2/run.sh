#!/bin/bash

echo "running example: `date`"
currentdir=`pwd`

# sets up directory structure in current example directory
echo
echo "   setting up example..."
echo

# cleans output files
mkdir -p OUTPUT_FILES
rm -rf OUTPUT_FILES/*

# stores setup
cp DATA/meshfem3D_files/Mesh_Par_file OUTPUT_FILES/
cp DATA/Par_file OUTPUT_FILES/

# use this to test a source that is at a GLL point in the corner of an element, shared by several elements and assembled in the mass matrix
cp -f DATA/FORCESOLUTION_at_the_corner_between_several_spectral_elements DATA/FORCESOLUTION
cp -f DATA/STATIONS_at_the_corner_between_several_spectral_elements DATA/STATIONS

# or use this to test a source that is inside a given spectral element
# cp -f DATA/FORCESOLUTION_inside_a_given_spectral_element DATA/FORCESOLUTION
# cp -f DATA/STATIONS_inside_a_given_spectral_element DATA/STATIONS

cp DATA/FORCESOLUTION OUTPUT_FILES/
cp DATA/STATIONS OUTPUT_FILES/


# get the number of processors, ignoring comments in the Par_file
NPROC=`grep ^NPROC DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`

BASEMPIDIR=`grep ^LOCAL_PATH DATA/Par_file | cut -d = -f 2 `
mkdir -p $BASEMPIDIR

# runs in-house mesher
if [ "$NPROC" -eq 1 ]; then
  # This is a serial simulation
  echo
  echo "  running mesher..."
  echo
  /usr/local/bin/xmeshfem3D
else
  # This is a MPI simulation
  echo
  echo "  running mesher on $NPROC processors..."
  echo
  mpirun -np $NPROC /usr/local/bin/xmeshfem3D 2>&1 | grep -v 'Read -1,'
fi
# checks exit code
if [[ $? -ne 0 ]]; then exit 1; fi

# runs database generation
if [ "$NPROC" -eq 1 ]; then
  # This is a serial simulation
  echo
  echo "  running database generation..."
  echo
  /usr/local/bin/xgenerate_databases
else
  # This is a MPI simulation
  echo
  echo "  running database generation on $NPROC processors..."
  echo
  mpirun -np $NPROC /usr/local/bin/xgenerate_databases 2>&1 | grep -v 'Read -1,'
fi
# checks exit code
if [[ $? -ne 0 ]]; then exit 1; fi

# runs simulation
if [ "$NPROC" -eq 1 ]; then
  # This is a serial simulation
  echo
  echo "  running solver..."
  echo
  /usr/local/bin/xspecfem3D
else
  # This is a MPI simulation
  echo
  echo "  running solver on $NPROC processors..."
  echo
  mpirun -np $NPROC /usr/local/bin/xspecfem3D 2>&1 | grep -v 'Read -1,'
fi
# checks exit code
if [[ $? -ne 0 ]]; then exit 1; fi

echo
echo "see results in directory: OUTPUT_FILES/"
echo
echo "done"
echo `date`

