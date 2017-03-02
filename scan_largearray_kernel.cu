#ifndef _PRESCAN_CU_
#define _PRESCAN_CU_

// includes, kernels
#include <assert.h>
#include "CONSTANTS.h"


<<<<<<< Updated upstream
=======

>>>>>>> Stashed changes
// Lab4: Host Helper Functions (allocate your own data structure...)

// Lab4: Device Functions


// Lab4: Kernel Functions
__global__ void computeKernel( float* odata, float* idata, unsigned int len)
{
	
	__shared__ int bid;
	
	int partial_sum = 0;
	bid  = blockIdx.x;
	__shared__ float temp[DEFAULT_NUM_ELEMENTS];
	temp[0] = 0;
	odata[0] = 0;
 	double total_sum;
	
	
	unsigned int tid = __mul24(threadIdx.y, 16) + threadIdx.x;
	unsigned int element;
	
	  	for(int j = 1; j < DEFAULT_NUM_ELEMENTS; j++)
	  	{ 		
	  		//element = __mul24(BLOCK_SIZE, blockIdx.x)+ j;
	  		total_sum += idata[j];
			temp[j] = temp[j-1]+idata[j-1];
			
	  	}
	  	
	  	syncthreads();

	  	
	  	
	  	for(int j = 0; j < DEFAULT_NUM_ELEMENTS; j++)
	  	{
	  	//element = __mul24(BLOCK_SIZE, blockIdx.x)+ j;
	  	odata[j] = temp[j];
	  	      
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

