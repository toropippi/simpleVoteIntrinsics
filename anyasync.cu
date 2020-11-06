/*
__any_sync,__all_syncのサンプル。しかし仕様がよくわからない。多分もう使わない(使えない)

Deprecation notice: __any, __all, and __ballot have been deprecated in CUDA 9.0 for all devices.

Removal notice: When targeting devices with compute capability 7.x or higher, __any, __all, and __ballot are no longer available and their sync variants should be used instead.

非推奨の通知：__ any、__ all、および__ballotは、すべてのデバイスのCUDA9.0で非推奨になりました。

削除通知：コンピューティング機能7.x以降のデバイスを対象とする場合、__ any、__ all、および__ballotは使用できなくなり、代わりにそれらの同期バリアントを使用する必要があります。
*/
#include <stdio.h>
#include <stdlib.h>


__global__ void anyatest(int *A,int *B) 
{
	unsigned int tx = threadIdx.x;
	//unsigned int mask = 0xffffffff;
	unsigned int mask = 0x0000001f;
	B[tx] = __any_sync(mask, A[tx]);
}




int main() {
	int N = 128;
	int* h_A = (int*)malloc(N * sizeof(int));
	int* h_B = (int*)malloc(N * sizeof(int));
	int *d_A,*d_B;
	cudaMalloc(&d_A, N * sizeof(int));
	cudaMalloc(&d_B, N * sizeof(int));
	
	for(int i=0;i<N;i++)
		h_A[i]=0;
	h_A[30]=1;
	h_A[31]=1;
	h_A[32+2]=1;
	
	//HostToDevice
	cudaMemcpy(d_A, h_A, N * sizeof(int), cudaMemcpyHostToDevice);

	anyatest <<<1, N >>> (d_A,d_B);
	cudaMemcpy(h_B, d_B, N * sizeof(int), cudaMemcpyDeviceToHost);
	
	for(int i=0;i<N;i++){
		printf("%d",h_B[i]);
		if (i%16==15)printf("\n");
	}

	cudaFree(d_A);
	cudaFree(d_B);
	return 0;
}
