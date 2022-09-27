#!/bin/bash
  
module load mpi/hpcx

NP=$1
HOSTFILE=$2
BASE_DIR=/opt
NCCL_TESTS_EXE=all_reduce_perf


mpirun -np $NP --bind-to numa --map-by ppr:8:node -x LD_LIBRARY_PATH=/usr/local/nccl-rdma-sharp-plugins/lib:$LD_LIBRARY_PATH -x NCCL_DEBUG=INFO -mca coll_hcoll_enable 0 -x NCCL_IB_PCI_RELAXED_ORDERING=1 -x UCX_TLS=tcp -x UCX_NET_DEVICES=eth0 -x CUDA_DEVICE_ORDER=PCI_BUS_ID -x NCCL_SOCKET_IFNAME=eth0 ${BASE_DIR}/nccl-tests/build/$NCCL_TESTS_EXE -b8 -f 2 -g 1 -e 8G -c 1