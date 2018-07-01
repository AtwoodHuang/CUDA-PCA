#include "cuda_runtime.h"
#include"cuda_runtime_api.h"
#include<stdio.h>
#include<stdlib.h>
#include <cusolverDn.h>
#include "Utilities.cuh"
void evd(float* d_covarianceMatrix, float*h_U, float*h_S, int Nrows, int Ncols)
{
	// cusolverǰ�ڲ���
	int work_size = 0;
	int *devInfo;           gpuErrchk(cudaMalloc(&devInfo, sizeof(int)));

	// cusolver��ʼ��
	cusolverDnHandle_t solver_handle;
	cusolverDnCreate(&solver_handle);

	// �ԽǾ���
	float *d_S;            gpuErrchk(cudaMalloc(&d_S, Nrows * sizeof(float)));

	// ��������ֵ�ֽ�����ռ�
	cusolveSafeCall(cusolverDnSsyevd_bufferSize(solver_handle, CUSOLVER_EIG_MODE_VECTOR, CUBLAS_FILL_MODE_LOWER, Nrows, d_covarianceMatrix, Nrows, d_S, &work_size));
	float *work;   gpuErrchk(cudaMalloc(&work, work_size * sizeof(float)));

	// ���ú�������ֵ�ֽ�
	cusolveSafeCall(cusolverDnSsyevd(solver_handle, CUSOLVER_EIG_MODE_VECTOR, CUBLAS_FILL_MODE_LOWER, Nrows, d_covarianceMatrix, Nrows, d_S, work, work_size, devInfo));
	int devInfo_h = 0;  gpuErrchk(cudaMemcpy(&devInfo_h, devInfo, sizeof(int), cudaMemcpyDeviceToHost));
	if (devInfo_h != 0) printf("Unsuccessful SVD execution\n\n");

	// ��GPUȡ������
	gpuErrchk(cudaMemcpy(h_S, d_S, Nrows * sizeof(float), cudaMemcpyDeviceToHost));
	gpuErrchk(cudaMemcpy(h_U, d_covarianceMatrix, Nrows * Nrows * sizeof(float), cudaMemcpyDeviceToHost));//��������������ԭ��ꇿ��g
																										  //�ͷſռ�
	cudaFree(devInfo);
	cudaFree(work);
	cudaFree(d_S);
	cusolverDnDestroy(solver_handle);
}