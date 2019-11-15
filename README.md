# Docker image for SPECFEM3D_Cartesian

SPECFEM3D docker build.

Forked from https://github.com/akrause2014/specfem3d with tweaks to produce a smaller docker image


## Build

Build the Docker container:

```
docker build -t specfem3d-docker:latest .
```

This creates a docker image with the tag "specfem3d-docker:latest".
You can choose any tag name and also specify version.

## Run container

Start the container and start a shell:

```
docker run -it <IMAGE_ID> /bin/sh
```

Compile and run the MPI example:

```
/home/mpiuser # mpirun --allow-run-as-root -n 4 --oversubscribe mpi_hello_world
Hello world from processor 3b285cd3e0f9, rank 0 out of 4 processors
Hello world from processor 3b285cd3e0f9, rank 1 out of 4 processors
Hello world from processor 3b285cd3e0f9, rank 2 out of 4 processors
Hello world from processor 3b285cd3e0f9, rank 3 out of 4 processors
```

Logging out will kill the container (and remove any data or changes you've made).

## Examples 

Two examples are includes which are designed ot be run on a single node

### Example 1

This is the default example distributed with SPECFEM3D source code. It is set to run on 4 processors on a single node. 
Start the container using a the run directory as a volume.

```
$ docker run -v `pwd`/example/example1:/home/mpiuser/example1 -it specfem3d-docker:latest /bin/sh
$ cd example1/
$ /bin/sh ./run.sh
```

This took about 25 mins to run on my laptop.

### Example 2

Is the `check_absolute_amplitude_of_force_source_seismograms/` example from the SPECFEM3d source code

```
$ docker run -v `pwd`/example/example2:/home/mpiuser/example2 -it specfem3d-docker:latest /bin/sh
$ cd example2/
$ /bin/sh ./run.sh
```

This takes quite a while to run


// ## Compose multiple Docker containers as MPI cluster
// 
// Create a swarm and deploy the app (see https://docs.docker.com/get-started/part3/):
// 
// ```
// docker swarm init
// docker stack deploy -c docker-compose.yml specfem3d
// ```
// 
// **Note:** If you have more than one node you may need to add them all to the swarm
// running `docker swarm join` - see https://docs.docker.com/get-started/part4/
// for details.
// 
// Run `./create_hostfile.sh` to discover the currently running MPI containers and
// write their IDs into a hostfile. The hostfile is transferred to
// the MPI head node. For example:
// 
// ```
// $ ./create_hostfile.sh
// f7623ce479dd
// 66ec19b1de2d
// e7d04fe28164
// HEAD NODE: e7d04fe28164
// ```
// 
// Note that this discovers only the containers running on the host where the
// script is run.
// 
// Log into the MPI head node with the container ID from the output above:
// 
// ```
// docker exec -it <CONTAINER_ID> /bin/sh
// ```
// 
// Within the container:
// ```
// su mpiuser
// mpirun --hostfile hostfile -np 6 a.out
// ```
// 
// Shut down the stack (from the host machine):
// ```
// docker stack rm specfem3d
// ```


// ## Run container non-interactively (with SSHD)
// 
// Run the container in non-interactive mode (this command does not return until
// you kill the container):
// ```
// docker run <IMAGE_ID>
// ```
// 
// Check that the container is running and find out the container ID:
// 
// ```
// $ docker ps
// CONTAINER ID        IMAGE               COMMAND               CREATED             STATUS              PORTS               NAMES
// 38e2ea53744d        e99ef04dc42f        "/usr/sbin/sshd -D"   31 minutes ago      Up 31 minutes       22/tcp              keen_ellis
// ```