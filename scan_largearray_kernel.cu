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
	__device__ float sums[STEPS];
	__device int my_block_count = 0;
	temp[0] = 0;
	int stride = 1;

	__shared__ unsigned int my_blockId;
	if (threadIdx.x==0)
	{
		my_blockId = atomicInc( &my_block_count, (unsigned int) -1 );
	}

	int tid = __mul24(threadIdx.y, 16)+threadIdx.x;
	int bid = blockIdx.x;
	int i_element = __mul24(bid,BLOCK_SIZE)+tid;

	double total_sum = 0;

	for (int j = 1; j < BLOCK_SIZE; j++)
	{
		total_sum += idata[j];
		temp[j] = temp[j-1]+idata[j-1];
	}
	syncthreads();
	sums[my_blockId] = total_sum;

	int partial_sum = 0;

	for(int i = 0; i < my_blockId; i++)
		partial_sum += sums[i];
	for(int j = 0; j < BLOCK_SIZE; j++)
		odata[j+(my_blockId*BLOCK_SIZE)] = partial_sum + temp[j];
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
