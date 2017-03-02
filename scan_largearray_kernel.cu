#ifndef _PRESCAN_CU_
#define _PRESCAN_CU_

// includes, kernels
#include <assert.h>
//#include <scan_largearray.cu>


#define NUM_BANKS 32
#define LOG_NUM_BANKS 5
// Lab4: You can use any other block size you wish.
#define BLOCK_SIZE 256
#define DEFAULT_NUM_ELEMENTS 512
#define STEPS DEFAULT_NUM_ELEMENTS/BLOCK_SIZE

// Lab4: Host Helper Functions (allocate your own data structure...)

// Lab4: Device Functions

__device__ float sums[STEPS];
__device__ unsigned int count = 0;
// Lab4: Kernel Functions
__global__ void computeKernel( float* odata, float* idata, unsigned int len)
{
	
	__shared__ int bid;
	
	int partial_sum = 0;
	bid  = blockIdx.x;
	__shared__ float temp[BLOCK_SIZE];
	temp[0] = 0;
	__shared__ double total_sum;
	
	
	unsigned int tid = __mul24(threadIdx.y, 16) + threadIdx.x;
	unsigned int element;
	
	  	for(int j = 0; j < BLOCK_SIZE; j++)
	  	{
	  		if (j== 0)
	  			total_sum = 0;
	  		else
	  		{
	  		element = __mul24(BLOCK_SIZE, blockIdx.x)+ j;
	  		total_sum += idata[element];
			temp[j] = temp[j-1]+idata[element-1];
			}
	  	}
	  	sums[bid] = total_sum;
	  	syncthreads();

	  	if(bid != 0)
	  	{
	  	partial_sum += sums[STEPS-bid];
	  	odata[bid*BLOCK_SIZE] = partial_sum;
	  	}
	  	else 
	  	{
	  	odata[bid] = 0;
	  	partial_sum = 0;
	  	}
	  	
	  	for(int j = 0; j < BLOCK_SIZE; j++)
	  	{
	  	 element = __mul24(BLOCK_SIZE, blockIdx.x)+ j;
	  	 	if(j == 0)
	  	 	odata[element] = partial_sum;
	  	      else
	  	       odata[element] = temp[j] + partial_sum;
	  	      
	  	}
	  	syncthreads();
	  
}



// **===-------- Lab4: Modify the body of this function -----------===**
// You may need to make multiple kernel calls, make your own kernel
// function in this file, and then call them from here.
void prescanArray(float *outArray, float *inArray, int numElements)
{

	//int size = DEFAULT_NUM_ELEMENTS * sizeof(float);
	//float * answer;
	// float * Adevice_in = AllocateDeviceArray(inArray);
	// CopyToDeviceArray(Adevice_in, inArray);
	// float * Adevice_out = AllocateDeviceArray(outArray);
	// CopyToDeviceArray(Adevice_out, outArray);

	dim3 dimGrid(DEFAULT_NUM_ELEMENTS/BLOCK_SIZE,1);
	dim3 dimBlock(16,16);

	unsigned int len = DEFAULT_NUM_ELEMENTS;
	computeKernel <<< dimGrid, dimBlock >>> (outArray , inArray, len);
	//cudaThreadSynchronize();
	//CopyFromDeviceArray(answer, outArray);
}
// **===-----------------------------------------------------------===**


#endif // _PRESCAN_CU_

