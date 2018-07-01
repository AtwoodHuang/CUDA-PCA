#include "cuda_runtime.h"
#include "cublas_v2.h"
#include"cuda_runtime_api.h"
#include<iostream>
#include<stdlib.h>
#include<stdio.h>

void tongjiliang(float*h_U, float*h_S, float *h_Tsquare, float *h_SPE, int pNcols, float*h_matrixtest, float *d_meanmatrix, float *h_biaozhuncha, int Nrows, int Ncols, int Ncolstest)
{
	float *d_U;
	float *d_S;
	float *d_t;
	float *d_t2;
	float *d_spe2;
	float *d_spe3;
	float *d_one;
	float *d_matrixtest;
	float *h_duijiaozhen = (float*)malloc(pNcols*pNcols * sizeof(float));
	float *h_one = (float*)malloc(Nrows*Nrows * sizeof(float));
	for (int i = 0; i < pNcols*pNcols; i++)
	{
		h_duijiaozhen[i] = 0;
	}
	for (int i = 0; i < pNcols; i++)
	{
		h_duijiaozhen[i*pNcols + i] = (1 / h_S[Nrows - pNcols + i]);
	}
	for (int i = 0; i <Nrows*Nrows; i++)
	{
		h_one[i] = 0;
	}
	for (int i = 0; i < Nrows; i++)
	{
		h_one[i*Nrows + i] = 1;
	}
	cudaMalloc(&d_matrixtest, Nrows*Ncolstest * sizeof(float));
	cudaMalloc(&d_U, Nrows*pNcols * sizeof(float));
	cudaMalloc(&d_t, pNcols*Ncolstest * sizeof(float));
	cudaMalloc(&d_t2, 1 * pNcols * sizeof(float));
	cudaMalloc(&d_S, pNcols*pNcols * sizeof(float));
	cudaMalloc(&d_one, Nrows*Nrows * sizeof(float));
	cudaMalloc(&d_spe2, Nrows*Nrows * sizeof(float));
	cudaMalloc(&d_spe3, 1 * Nrows * sizeof(float));
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
	cublasSetVector(Nrows*Ncolstest, sizeof(float), h_matrixtest, 1, d_matrixtest, 1);
	cublasSetVector(Nrows*pNcols, sizeof(float), h_U + (Nrows - pNcols)*Nrows, 1, d_U, 1);
	cublasSetVector(pNcols*pNcols, sizeof(float), h_duijiaozhen, 1, d_S, 1);
	cublasSetVector(Nrows*Nrows, sizeof(float), h_one, 1, d_one, 1);
	float a = 1; float b = -1;
	cublasSgeam(handle, CUBLAS_OP_N, CUBLAS_OP_N, Nrows, Ncols, &a, d_matrixtest, Nrows, &b, d_meanmatrix, Nrows, d_matrixtest, Nrows);
	cublasSgeam(handle, CUBLAS_OP_N, CUBLAS_OP_N, Nrows, (Ncolstest - Ncols), &a, (d_matrixtest + Nrows*Ncols), Nrows, &b, d_meanmatrix, Nrows, (d_matrixtest + Nrows*Ncols), Nrows);
	for (int i = 0; i < Nrows; i++)
	{
		a = (sqrt(Ncols - 1)) / (*(h_biaozhuncha + i));
		cublasSscal(handle, Ncolstest, &a, (d_matrixtest + i), Nrows);
	}
	a = 1.0, b = 0;
	cublasSgemm(handle, CUBLAS_OP_T, CUBLAS_OP_N, pNcols, Ncolstest, Nrows, &a, d_U, Nrows, d_matrixtest, Nrows, &b, d_t, pNcols);
	for (int i = 0; i < Ncolstest; i++)
	{
		cublasSgemm(handle, CUBLAS_OP_T, CUBLAS_OP_N, 1, pNcols, pNcols, &a, (d_t + i*pNcols), pNcols, d_S, pNcols, &b, d_t2, 1);
		cublasSdot(handle, pNcols, d_t2, 1, (d_t + i*pNcols), 1, (h_Tsquare + i));
	}
	cudaDeviceSynchronize();
	cublasSgemm(handle, CUBLAS_OP_N, CUBLAS_OP_T, Nrows, Nrows, pNcols, &a, d_U, Nrows, d_U, Nrows, &b, d_spe2, Nrows);
	a = 1, b = -1;
	cublasSgeam(handle, CUBLAS_OP_N, CUBLAS_OP_N, Nrows, Nrows, &a, d_one, Nrows, &b, d_spe2, Nrows, d_spe2, Nrows);
	a = 1, b = 0;
	for (int i = 0; i < Ncolstest; i++)
	{
		cublasSgemm(handle, CUBLAS_OP_T, CUBLAS_OP_N, 1, Nrows, Nrows, &a, (d_matrixtest + i*Nrows), Nrows, d_spe2, Nrows, &b, d_spe3, 1);
		cublasSdot(handle, Nrows, d_spe3, 1, (d_matrixtest + i*Nrows), 1, (h_SPE + i));
	}
	cudaDeviceSynchronize();
	cublasDestroy(handle);
	free(h_duijiaozhen);
	free(h_one);
	cudaFree(d_matrixtest);
	cudaFree(d_U);
	cudaFree(d_t);
	cudaFree(d_t2);
	cudaFree(d_S);
	cudaFree(d_one);
	cudaFree(d_spe2);
	cudaFree(d_spe3);
}
