#ifndef _PRESCAN_CU_
#define _PRESCAN_CU_

// includes, kernels
#include <assert.h>
#include "CONSTANTS.h"


// Lab4: Host Helper Functions (allocate your own data structure...)

// Lab4: Device Functions
__device__ int count = -1;
__device__ float partial[STEPS];
//__device__ double global_block_sum = 0;

// Lab4: Kernel Functions
__global__ void computeKernel( float* odata, float* idata, unsigned int len)
{
	int tid = __mul24(threadIdx.y, 16) + threadIdx.x;
	int bid = blockIdx.x;
	int element;
	
	__shared__  int mbid;
	if(tid == 0)
		mbid = atomicAdd(&count, 1);
	syncthreads();
		
	__shared__ float temp[BLOCK_SIZE];
	
	
	odata[0] = 0;
 	
 	
	
	temp[0] = 0;
	
	syncthreads();
	
	//each thread block does a partial summation
	for(int i = 0; i < STEPS; i++)
	{
		 	for(int j = 1; j < BLOCK_SIZE; j++)
		  	{ 		
		  		element = __mul24(BLOCK_SIZE, bid)+ j;
				temp[j] = temp[j-1]+idata[element-1];
			
		  	}
		  	syncthreads();
	 }
	 //end of parallel sums per TB
	 
		
	
	for(int i = 0; i < STEPS; i++)
		if (i == 0)
		{
			for(int j = 0; j < BLOCK_SIZE; j++)
		  	{
		  	odata[j] = temp[j];
		  	//odata[j] = bid;
		  	}
		  	partial[0] = temp[BLOCK_SIZE-1]+idata[BLOCK_SIZE-1];
		  	syncthreads();
		  	
		}
		else
		{
		        //partial[0] += temp[0];
		  	for(int j = 0; j < BLOCK_SIZE; j++)
		  	{
		  	element = __mul24(BLOCK_SIZE, 1)+ j;
		  	odata[element] = partial[0]+temp[j];
		  	//odata[element]= bid;
		  	}
		  	partial[1] = temp[BLOCK_SIZE-1];
		  	syncthreads();
		  	
		}	
		syncthreads();
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

