#define DEFAULT_NUM_ELEMENTS 256
#define NUM_BANKS 32
#define LOG_NUM_BANKS 5
#define BLOCK_SIZE 128   //128 or 32 seem to be safe and work for all sizes
#define STEPS ((DEFAULT_NUM_ELEMENTS-1)/BLOCK_SIZE)+1
#define PRINT 1
#define PRINT_NUM 16
