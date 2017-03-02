#ifndef _PRESCAN_CU_
#define _PRESCAN_CU_

// includes, kernels
#include <assert.h>
//#include <scan_largearray.cu>


#define NUM_BANKS 32
#define LOG_NUM_BANKS 5
// Lab4: You can use any other block size you wish.
#define BLOCK_SIZE 256
#define DEFAULT_NUM_ELEMENTS 256

// Lab4: Host Helper Functions (allocate your own data structure...)
float* AllocateDeviceArray(float * A)
{
	float * Adevice = A;
	int size = DEFAULT_NUM_ELEMENTS * sizeof(float);
	cudaMalloc((void**)&Adevice, size);
	return Adevice;
}



void CopyToDeviceArray(float * Adevice, float * Ahost)
{
	int size = DEFAULT_NUM_ELEMENTS * sizeof(float);
	cudaMemcpy(Adevice, Ahost, size,cudaMemcpyHostToDevice);
}

void CopyFromDeviceArray(float * Ahost, float * Adevice)
{
	int size = DEFAULT_NUM_ELEMENTS * sizeof(float);
	cudaMemcpy(Ahost, Adevice, size, cudaMemcpyDeviceToHost);
}

// Lab4: Device Functions


// Lab4: Kernel Functions
__global__ void computeKernel( float* odata, float* idata, unsigned int len)
{

	__shared__ float temp[BLOCK_SIZE]; // allocated on invocation
	temp[0] = 0;
	int stride = 1;
	int tid = __mul24(threadIdx.y, 16)+threadIdx.x;
	int bid = blockIdx.x;
	int i_element = __mul24(bid,BLOCK_SIZE)+tid;

	odata[0] = 0;
	double total_sum = 0;

	if(tid==0)
	{
		for(unsigned int i = 1; i < len; ++i)
		{
			total_sum += idata[i-1];
			odata[i] = idata[i-1] + odata[i-1];
		}
	}

		syncthreads();
		//if (total_sum != odata[len-1])
		//printf("Warning: exceeding single-precision accuracy.  Scan will be inaccurate.\n");
}



// **===-------- Lab4: Modify the body of this function -----------===**
// You may need to make multiple kernel calls, make your own kernel
// function in this file, and then call them from here.
void prescanArray(float *outArray, float *inArray, int numElements)
{

	int size = DEFAULT_NUM_ELEMENTS * sizeof(float);
	float * answer;
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
