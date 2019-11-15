FROM alpine:3.8

RUN apk --no-cache --update-cache add \
    wget \
    bash \
    gcc \
    gfortran \
    git \
    zlib \
    zlib-dev \
    build-base \
    libgfortran \
    gsl \
    make \
    openssh \
    perl \
    linux-headers

# Build MPI from source as it stops compiler conflict with gcc/ gfortran versions from repos.
ENV OPEN_MPI_VERSION 4.0.0
RUN wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.0.tar.gz \
    && tar xzf openmpi-${OPEN_MPI_VERSION}.tar.gz \
    && cd openmpi-${OPEN_MPI_VERSION} \
    && ./configure --prefix=/usr/local \
    && make all install \
    && cd / \
    && rm -r openmpi-4.0.0 openmpi-4.0.0.tar.gz
    
# MPI user   
ENV USER mpiuser
ENV HOME /home/${USER}
RUN adduser ${USER} --disabled-password --gecos "" && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# compile SPECFEM3D - note the use of single command and removal of the directory drastically reducing the image size
WORKDIR ${HOME}
RUN git clone --recursive --branch master https://github.com/geodynamics/specfem3d.git && \
	cd specfem3d && \
    ./configure FC=gfortran CC=gcc MPIFC=mpif90 --with-mpi && \
    make xmeshfem3D xgenerate_databases xspecfem3D xdecompose_mesh && \
    mv ./bin/* /usr/local/bin && \
    cd ${HOME} && \
    rm -r ./specfem3d

# add MPI hello world and compile
ADD mpi_hello_world.c ${HOME}/mpi_hello_world.c
RUN chown -R ${USER}:${USER} ${HOME}/mpi_hello_world.c
RUN cd ${HOME} && mpicc -o mpi_hello_world mpi_hello_world.c

# User config
USER mpiuser

#
# At this stage we are not to worried about ssh'ing into the nodes so we'll leve this stuff out of theimage for the moment
#

#RUN ssh-keygen -A \
#    && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
#    && sed -i s/^#PasswordAuthentication\ yes/PasswordAuthentication\ no/ /etc/ssh/sshd_config

##ENV SSHDIR ${HOME}/.ssh/
##RUN mkdir -p ${SSHDIR}
##ADD ssh/config ${SSHDIR}/config
##ADD ssh/id_rsa ${SSHDIR}/id_rsa
##ADD ssh/id_rsa.pub ${SSHDIR}/id_rsa.pub
##ADD ssh/id_rsa.pub ${SSHDIR}/authorized_keys
##RUN chown ${USER}:${USER} ${SSHDIR}/* \
##    && chmod 600 ${SSHDIR}/* \
##    && echo 'mpiuser:2q3450anwf54k' | chpasswd


#EXPOSE 22
#CMD ["/usr/sbin/sshd", "-D"]
