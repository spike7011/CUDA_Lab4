#ifndef _PRESCAN_CU_
#define _PRESCAN_CU_

// includes, kernels
#include <assert.h>



// Lab4: Host Helper Functions (allocate your own data structure...)

// Lab4: Device Functions
__device__ uint32_t count = 0;    //keeps track of number of launched blocks
__device__ uint32_t count2 = 0;  // keeps track of which blocks are finished doing local scan
__device__ uint32_t done = 0;
__device__ double partial[STEPS];

// Lab4: Kernel Functions
__global__ void computeKernel( float* odata, float* idata, unsigned int len)
{
	uint32_t tid = threadIdx.x;
	uint32_t bid = blockIdx.x;
	__shared__ uint32_t index;
	
	__shared__ uint32_t  mbid;
	__shared__ uint32_t  mbid2;
	__shared__ double temp[BLOCK_SIZE];
	__shared__ int prec;
	if(tid == 0)
	{
		mbid = atomicInc(&count, (unsigned int) -1);
		index = __mul24(BLOCK_SIZE, mbid);
		temp[0]=0;
	 	for(int j = 1; j < BLOCK_SIZE; j++)
  	{ 		
			temp[j] = temp[j-1]+idata[index + j - 1];
	  }
		partial[mbid] = temp[BLOCK_SIZE-1] + idata[index + BLOCK_SIZE-1];
	}
 
  while(count2 < mbid)
    syncthreads();

  mbid2= atomicInc(&count2, (unsigned int) -1 );   
 	
	__shared__ double p;
 	
  if(tid == 0)
	{
    p=0;
  	if (mbid>0) 
      for (int o=0;o<mbid;o++)
        p += partial[o];
  }

  syncthreads();
  
	odata[index+tid] =  p + temp[tid] ;
	
  syncthreads();
}
	


__global__ void computeKernel_o2( float* odata, float* idata, unsigned int len)
{
	uint32_t tid = threadIdx.x;
	uint32_t bid = blockIdx.x;
	__shared__ uint32_t index;
	
	__shared__ uint32_t  mbid;
	__shared__ uint32_t  mbid2;
	__shared__ float temp[BLOCK_SIZE];
	__shared__ int prec;
	if(tid == 0)
	{
   if(mbid == 0)
    odata[0]=0;
		mbid = atomicInc(&count, (unsigned int) -1);
  }
  syncthreads();
  
// magic begins
	index = __mul24(BLOCK_SIZE, mbid);
	temp[0]=0;
 
	//reduction step
	memcpy(temp, idata+index, sizeof(float)*BLOCK_SIZE);
  int stride = 1;
  while (stride < BLOCK_SIZE)
  {
     int pos = (tid+1)*stride*2 -1;
     if (pos < BLOCK_SIZE)
       if((pos-stride) >= 0)
       temp[pos] = temp[pos] + temp[pos-stride];
     stride = stride*2;
    syncthreads();
  }
  
  
  
  stride = BLOCK_SIZE / 2;
  while(stride > 0)
  {
    int index = (threadIdx.x+1)*stride*2 - 1;
    if(index < BLOCK_SIZE) 
      temp[index+stride] = temp[index] + temp[index+stride];
    stride /= 2;
  syncthreads();
  }
   
  partial[mbid] = temp[BLOCK_SIZE-1];
 
 	/*or(int j = 1; j < BLOCK_SIZE; j++)
 	{ 		
			      
      //start modifiying here
      
      temp[j] = temp[j-1]+idata[index + j - 1];
  }
	partial[mbid] = temp[BLOCK_SIZE-1] + idata[index + BLOCK_SIZE-1];
*/

// magic ends
 
  while(count2 < mbid)
    syncthreads();

  mbid2= atomicInc(&count2, (unsigned int) -1 );   
 	
	__shared__ double p;
 	
  if(tid == 0)
	{
    p=0;
  	if (mbid>0) 
      for (int o=0;o<mbid;o++)
        p += partial[o];
  }

  syncthreads();
  
	odata[index+tid+1] =  temp[tid] + p;
	
  syncthreads();
}
	




// **===-------- Lab4: Modify the body of this function -----------===**
// You may need to make multiple kernel calls, make your own kernel
// function in this file, and then call them from here.
void prescanArray(float *outArray, float *inArray, int numElements)
{

	dim3 dimGrid(STEPS,1);
	dim3 dimBlock(BLOCK_SIZE,1);

	unsigned int len = DEFAULT_NUM_ELEMENTS;
	computeKernel <<< dimGrid, dimBlock >>> (outArray , inArray, len);
}
// **===-----------------------------------------------------------===**


#endif // _PRESCAN_CU_

