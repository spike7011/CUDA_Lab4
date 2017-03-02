#ifndef _PRESCAN_CU_
#define _PRESCAN_CU_

// includes, kernels
#include <assert.h>
#include "CONSTANTS.h"


// Lab4: Host Helper Functions (allocate your own data structure...)

// Lab4: Device Functions
__device__ unsigned int count = 0;
__device__ float partial_sum = 0;

// Lab4: Kernel Functions
__global__ void computeKernel( float* odata, float* idata, unsigned int len)
{

	__shared__ unsigned int mbid;
	__shared__ float temp[BLOCK_SIZE];
	float partial[STEPS];
	
	unsigned int tid = threadIdx.x+__mul24(16,threadIdx.y);
	if(tid == 0)
	{
	mbid = atomicInc(&count, (unsigned int) -1);
	}
	syncthreads();
	
	unsigned int bid = blockIdx.x;
	
	odata[0] = 0;
 	__shared__ double block_sum;
 	
	unsigned int element;
	
	
	
	for(int i = 0; i < STEPS; i++)
	{
			block_sum = 0;
			temp[0] = 0;
		 	for(int j = 1; j < BLOCK_SIZE; j++)
		  	{ 		
		  		element = __mul24(BLOCK_SIZE, bid)+ j;
		  		block_sum += idata[element];
				temp[j] = temp[j-1]+idata[element-1];
			
		  	}
		  	if(i== 0)
		  	partial[i] = 0;
		  	else partial[i] = block_sum+partial[i-1];
		  	syncthreads();
	 }
		
	for(int i = 0; i < STEPS;i++)
	if(i == mbid-1)
	{
	  	for(int j = 0; j < BLOCK_SIZE; j++)
	  	{
	  	element = __mul24(BLOCK_SIZE, i)+ j;
	  	odata[element] = temp[j]+partial[i];
	  	}
	  	syncthreads();
	  }
} 
	 




// **===-------- Lab4: Modify the body of this function -----------===**
// You may need to make multiple kernel calls, make your own kernel
// function in this file, and then call them from here.
void prescanArray(float *outArray, float *inArray, int numElements)
{

	dim3 dimGrid(DEFAULT_NUM_ELEMENTS/BLOCK_SIZE,1);
	dim3 dimBlock(16,16);

	unsigned int len = DEFAULT_NUM_ELEMENTS;
	computeKernel <<< dimGrid, dimBlock >>> (outArray , inArray, len);
}
// **===-----------------------------------------------------------===**


#endif // _PRESCAN_CU_

