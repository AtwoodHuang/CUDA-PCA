#include "cuda_runtime.h"
#include"cuda_runtime_api.h"
#include "cublas_v2.h"
#include<iostream>
#include<stdlib.h>
#include<stdio.h>
float* covarianceMatrix(float*h_matrix, float *d_meanmatrix, float *h_biaozhuncha, int Nrows, int Ncols)
{
	float *d_matrix;
	float *d_covarianceMatrix;
	float * h_Ncols = (float *)malloc(Ncols * Ncols * sizeof(float));;
	float *d_Ncols;
	for (int i = 0; i < Ncols*Ncols; i++)
		h_Ncols[i] = 1.0 / Ncols;
	cudaMalloc(&d_matrix, Nrows*Ncols * sizeof(float));
	cudaMalloc(&d_Ncols, Ncols*Ncols * sizeof(float));
	cudaMalloc(&d_covarianceMatrix, Nrows*Nrows * sizeof(float));
	cublasStatus_t status;
	cublasHandle_t handle;
	status = cublasCreate(&handle);
	if (status != CUBLAS_STATUS_SUCCESS)
	{
		if (status == CUBLAS_STATUS_NOT_INITIALIZED)
		{
			printf("CUBLAS 对象初始化出错");
			getchar();
		}
	}
	cublasSetVector(Nrows*Ncols, sizeof(float), h_matrix, 1, d_matrix, 1);
	cublasSetVector(Ncols*Ncols, sizeof(float), h_Ncols, 1, d_Ncols, 1);
	float a = 1; float b = 0;
	cublasSgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, Nrows, Ncols, Ncols, &a, d_matrix, Nrows, d_Ncols, Ncols, &b, d_meanmatrix, Nrows);
	a = 1; b = -1;
	cublasSgeam(handle, CUBLAS_OP_N, CUBLAS_OP_N, Nrows, Ncols, &a, d_matrix, Nrows, &b, d_meanmatrix, Nrows, d_matrix, Nrows);
	for (int i = 0; i < Nrows; i++)
		cublasSnrm2(handle, Ncols, (d_matrix + i), Nrows, (h_biaozhuncha + i));
	cudaDeviceSynchronize();
	for (int i = 0; i < Nrows; i++)
	{
		a = (sqrt(Ncols - 1)) / (*(h_biaozhuncha + i));
		cublasSscal(handle, Ncols, &a, (d_matrix + i), Nrows);
	}
	a = 1.0 / (Ncols - 1); b = 0;
	cublasSgemm(handle, CUBLAS_OP_N, CUBLAS_OP_T, Nrows, Nrows, Ncols, &a, d_matrix, Nrows, d_matrix, Nrows, &b, d_covarianceMatrix, Nrows);
	cublasDestroy(handle);
	free(h_Ncols);
	cudaFree(d_matrix);
	cudaFree(d_Ncols);
	return d_covarianceMatrix;

}