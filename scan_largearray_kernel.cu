#ifndef _PRESCAN_CU_
#define _PRESCAN_CU_

// includes, kernels
#include <assert.h>



// Lab4: Host Helper Functions (allocate your own data structure...)

// Lab4: Device Functions
__device__ uint32_t count = 0;    //keeps track of number of launched blocks
__device__ uint32_t count2 = 0;  // keeps track of which blocks are finished doing local scan
__device__ float partial[100];
//__device__ double global_block_sum = 0;

// Lab4: Kernel Functions
__global__ void computeKernel( float* odata, float* idata, unsigned int len)
{
	uint32_t tid = threadIdx.x;
	uint32_t bid = blockIdx.x;
	__shared__ uint32_t index;
	
	__shared__ uint32_t  mbid;
	__shared__ float temp[BLOCK_SIZE];
	
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
	  
	  //index = __mul24(BLOCK_SIZE, mbid);
		}
   
   if(tid == 0)
     atomicInc(&count2, (unsigned int) -1 );
   syncthreads();
   int done = 0;
  
	
	float p = 0;
	if (mbid>0) 
    for (int o=0;o<mbid;o++)
      p += partial[o];
	odata[index+tid] = p + temp[tid] ;
	
  syncthreads();
  
 
}
	
__global__ void computeKernel_o1( float* odata, float* idata, unsigned int len)
{

	
	int tid = threadIdx.x;
	int bid = blockIdx.x;
	if(bid == 0 && tid == 0)
		odata[0] = 0;
	__shared__  int mbid;
	if(tid == 0)
		mbid = atomicAdd(&count, 1);
	syncthreads();
	//each thread block obtains it's local blockId in the shared variable mbid
	
	
	
	int element;
	
	
		
	__shared__ float temp[BLOCK_SIZE+1];
	for (int j = 0; j < STEPS; j++)
	{
		int stride = 2;
		
		memcpy(temp, idata+j*BLOCK_SIZE, sizeof(float)*BLOCK_SIZE);
		while(stride < PRINT_NUM)
		{
		if(tid<BLOCK_SIZE)
			if((tid+1)%stride == 0)
				temp[tid] = temp[tid] + temp[tid-stride/2];
		syncthreads();
		stride*=2;
		}
		
		//post scan step
		stride /=2 ;
		while(stride > 1)
		{
		if(tid < BLOCK_SIZE && tid != 0)
			if(tid - stride >= 0)
					if((tid-stride)%(stride/2) == 0)
						temp[tid] += temp[tid-stride/2];
		syncthreads();
		stride /= 2;
		
		}
		
			
	 }//syncthreads();
	
	 
	
	
	
	
	for(int i = 0; i < STEPS; i++)
	{
		if (bid == 0 )
		{
			for(int j = 0; j < BLOCK_SIZE; j++)
		  	{
		  	odata[j] = temp[j];
		  	//odata[j] = bid;
		  	}
		  	partial[0] = temp[BLOCK_SIZE-1]+idata[BLOCK_SIZE-1];
		  	//syncthreads();
		  	
		}
		/*else if (bid <= count2)
		{
		        //partial[0] += temp[0];
		  	for(int j = 0; j < 8; j++)
		  	{
		  	element = __mul24(BLOCK_SIZE, bid)+ j;
		  	odata[element] = temp[j]; //+ partial[bid-1];
		  	//odata[element]= partial[bid-1];
		  	}
		  	partial[bid] = temp[BLOCK_SIZE-1]+partial[bid-1];//+idata[BLOCK_SIZE*i-1];
		  	//syncthreads();
		  	
		}	*/
		syncthreads();
		
	}
	
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

