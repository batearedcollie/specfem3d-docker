#!/bin/bash

echo "running example: `date`"
currentdir=`pwd`

# sets up directory structure in current example directory
echo
echo "   setting up example..."
echo

rm -f -r OUTPUT_FILES

mkdir -p OUTPUT_FILES
mkdir -p OUTPUT_FILES/DATABASES_MPI

# stores setup
cp DATA/Par_file OUTPUT_FILES/
cp DATA/CMTSOLUTION OUTPUT_FILES/
cp DATA/STATIONS OUTPUT_FILES/

# get the number of processors, ignoring comments in the Par_file
NPROC=`grep ^NPROC DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2 | cut -d \# -f 1`
echo "The simulation will run on NPROC = " $NPROC " MPI tasks"

# decomposes mesh using the pre-saved mesh files in MESH-default
echo
echo "  decomposing mesh..."
echo
/usr/local/bin/xdecompose_mesh $NPROC ./MESH-default ./OUTPUT_FILES/DATABASES_MPI/

# runs database generation - note the grep command filters out some annoying error messages for mpi on docker
echo
echo "  running database generation on $NPROC processors..."
echo
mpirun -np $NPROC  /usr/local/bin/xgenerate_databases 2>&1 | grep -v 'Read -1,'

# runs simulation - note the grep command filters out some annoying error messages for mpi on docker
echo
echo "  running solver on $NPROC processors..."
echo
mpirun -np $NPROC  /usr/local/bin/xspecfem3D 2>&1 | grep -v 'Read -1,'

echo
echo "see results in directory: OUTPUT_FILES/"
echo
echo "done"
echo `date`


