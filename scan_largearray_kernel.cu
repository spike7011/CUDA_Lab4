#ifndef _PRESCAN_CU_
#define _PRESCAN_CU_

// includes, kernels
#include <assert.h>
//#include <scan_largearray.cu>


#define NUM_BANKS 32
#define LOG_NUM_BANKS 5
// Lab4: You can use any other block size you wish.
#define BLOCK_SIZE 256
#define DEFAULT_NUM_ELEMENTS 16000000

// Lab4: Host Helper Functions (allocate your own data structure...)
float* AllocateDeviceArray(float * A)
{
	float * Adevice = A;
	int size = DEFAULT_NUM_ELEMENTS * sizeof(float);
	cudaMalloc((void**)&Adevice, size);
	return Adevice;
}

// Allocate a matrix of dimensions height*width
//	If init == 0, initialize to all zeroes.
//	If init == 1, perform random initialization.

// Copy a host matrix to a device matrix.
void CopyToDeviceArray(float * Adevice, float * Ahost)
{
	int size = DEFAULT_NUM_ELEMENTS * sizeof(float);
	cudaMemcpy(Adevice, Ahost, size,cudaMemcpyHostToDevice);
}

// Copy a device matrix to a host matrix.
void CopyFromDeviceArray(float * Ahost, float * Adevice)
{
	int size = DEFAULT_NUM_ELEMENTS * sizeof(float);
	cudaMemcpy(Ahost, Adevice, size, cudaMemcpyDeviceToHost);
}

// Lab4: Device Functions


// Lab4: Kernel Functions
__global__ void computeKernel( float* reference, float* idata, unsigned int len)
{
	// reference[0] = 0;
	// double total_sum = 0;
	// for( unsigned int i = 1; i < len; ++i)
	// {
	//     total_sum += idata[i-1];
	//     reference[i] = idata[i-1] + reference[i-1];
	// }
	// if (total_sum != reference[len-1])
	//     printf("Warning: exceeding single-precision accuracy.  Scan will be inaccurate.\n");

}



// **===-------- Lab4: Modify the body of this function -----------===**
// You may need to make multiple kernel calls, make your own kernel
// function in this file, and then call them from here.
void prescanArray(float *outArray, float *inArray, int numElements)
{

	int size = DEFAULT_NUM_ELEMENTS * sizeof(float);
	float * Adevice_in = AllocateDeviceArray(inArray);
	CopyToDeviceArray(Adevice_in, inArray);
	float * Adevice_out = AllocateDeviceArray(outArray);
	CopyToDeviceArray(Adevice_out, outArray);

	dim3 dimGrid(DEFAULT_NUM_ELEMENTS/BLOCK_SIZE,1);
	dim3 dimBlock(16,16);

 	unsigned int len = DEFAULT_NUM_ELEMENTS;
	computeKernel << dimGrid, dimBlock >>> (Adevice_out ,Adevice_in, len);
	cudaThreadSynchronize();
	CopyFromDeviceArray(outArray, Adevice_out);
}
// **===-----------------------------------------------------------===**


#endif // _PRESCAN_CU_
