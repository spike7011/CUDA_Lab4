#ifndef _PRESCAN_CU_
#define _PRESCAN_CU_

// includes, kernels
#include <assert.h>


#define NUM_BANKS 32
#define LOG_NUM_BANKS 5
// Lab4: You can use any other block size you wish.
#define BLOCK_SIZE 256

// Lab4: Host Helper Functions (allocate your own data structure...)


// Lab4: Device Functions


// Lab4: Kernel Functions


// **===-------- Lab4: Modify the body of this function -----------===**
// You may need to make multiple kernel calls, make your own kernel
// function in this file, and then call them from here.
void prescanArray(float *outArray, float *inArray, int numElements)
{

	extern __shared__ float temp[];// allocated on invocation
	int thid = threadIdx.x;
	int offset = 1;
	temp[2*thid] = inArray[2*thid]; // load input into shared memory
	temp[2*thid+1] = inArray[2*thid+1];
	for (int d = numElements>>1; d > 0; d >>= 1) // build sum in place up the tree
	{
		__syncthreads();
		if (thid < d)
		{
			int ai = offset*(2*thid+1)-1;
			int bi = offset*(2*thid+2)-1;
			temp[bi] += temp[ai];
		}
		offset *= 2;
	}
	if (thid == 0) { temp[numElements - 1] = 0; } // clear the last element
	for (int d = 1; d < numElements; d *= 2) // traverse down tree & build scan
	{
		offset >>= 1;
		__syncthreads();
		if (thid < d)
		{
			int ai = offset*(2*thid+1)-1;
			int bi = offset*(2*thid+2)-1;
			float t = temp[ai];
			temp[ai] = temp[bi];
			temp[bi] += t;
		}
	}
	__syncthreads();
	outArray[2*thid] = temp[2*thid]; // write results to device memory
	outArray[2*thid+1] = temp[2*thid+1];

}
// **===-----------------------------------------------------------===**


#endif // _PRESCAN_CU_
