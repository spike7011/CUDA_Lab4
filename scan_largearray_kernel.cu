#ifndef _PRESCAN_CU_
#define _PRESCAN_CU_

// includes, kernels
#include <assert.h>
#include <stdint.h>
#define BLOCK_SIZE  1024  //128 or 32 seem to be safe and work for all sizes

// Lab4: Host Helper Functions (allocate your own data structure...)

// Lab4: Device Functions
//__device__ uint32_t count = 0;    //keeps track of number of launched blocks
__device__ uint32_t finished_blocks = 0;  // keeps track of which blocks are finished doing local scan
__device__ uint32_t partial[100000];


__global__ void computeKernel( float* odata, float* idata, unsigned int len, uint32_t STEPS)
{
    uint32_t tid = threadIdx.x;
    uint32_t index;
    partial[0]=0;
    __shared__ uint32_t temp[BLOCK_SIZE];
    index = __mul24(BLOCK_SIZE, blockIdx.x);
    temp[tid]= *(idata+index+tid);
    syncthreads();

    uint32_t stride = 1;

    while (stride < BLOCK_SIZE)
    {
        int index = __mul24(tid+1,stride*2) - 1;
        if (index < BLOCK_SIZE)
            temp[index] = temp[index] + temp[index-stride];
        stride = stride << 1;
        syncthreads();
    }

    syncthreads();
    stride = BLOCK_SIZE;
    while(stride > 1)
    {
        int index = __mul24(tid+1,stride) - 1;
        stride = stride >> 1;
        if(index+stride < BLOCK_SIZE)
            temp[index+stride] += temp[index];
        syncthreads();
    }

    while(finished_blocks < blockIdx.x)
        syncthreads();

	float pa=0;

    if(tid == 0)
    {

        if (blockIdx.x<STEPS-1)
            partial[blockIdx.x+1] = partial[blockIdx.x]+temp[BLOCK_SIZE-1];

        atomicInc(&finished_blocks, STEPS);
    }
    syncthreads();

    if ( blockIdx.x>0 )
        pa=partial[blockIdx.x];

    if (index+tid+1 < len)
        odata[index+tid+1] =  temp[tid] + pa;
    else
        odata[0] = 0;
}

// **===-------- Lab4: Modify the body of this function -----------===**
// You may need to make multiple kernel calls, make your own kernel
// function in this file, and then call them from here.
void prescanArray(float *outArray, float *inArray, int numElements)
{
  uint32_t STEPS = ((numElements-1)/BLOCK_SIZE)+1;

	dim3 dimGrid(STEPS,1);
	dim3 dimBlock(BLOCK_SIZE,1);


	computeKernel <<< dimGrid, dimBlock >>> (outArray , inArray, numElements, STEPS);
}
// **===-----------------------------------------------------------===**




#endif // _PRESCAN_CU_
