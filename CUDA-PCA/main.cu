#include "cuda_runtime.h"
#include<stdio.h>
#include<stdlib.h>
#include"cuda_runtime_api.h"
#include <time.h>
#include <windows.h>
float* covarianceMatrix(float*h_matrix, float *d_meanmatrix, float *h_biaozhuncha, int Nrows, int Ncols);
void evd(float* d_covarianceMatrix, float*h_U, float*h_S, int Nrows, int Ncols);
void Matrixinput(float*h_matrix, float*h_matrixtest, int Nrows, int Ncols, int Nrowstest, int Ncolstest, bool zhengchang, bool ceshi, char **argv);
void tongjiliang(float*h_U, float*h_S, float *h_Tsquare, float *h_SPE, int pNcols, float*h_matrixtest, float *d_meanmatrix, float *h_biaozhuncha, int Nrows, int Ncols, int Ncolstest);
int main(int argc, char **argv)
{
	clock_t startime;
	clock_t endtime;
	startime = clock();
	bool zhengchang = true;
	bool ceshi = true;
	int Nrows = atoi(argv[3]);
	int Ncols = atoi(argv[4]);
	int Nrowstest = atoi(argv[5]);
	int Ncolstest = atoi(argv[6]);
	if (Nrows > Ncols)
	{
		zhengchang = false;
		int c = Nrows;
		Nrows = Ncols;
		Ncols = c;
	}
	if (Nrowstest > Ncolstest)
	{
		ceshi = false;
		int d = Nrowstest;
		Nrowstest = Ncolstest;
		Ncolstest = d;
	}
	float sum = 0;
	float sum1 = 0;
	int pNcols = 0;
	float *h_U = (float *)malloc(Nrows * Nrows * sizeof(float));
	float *h_S = (float *)malloc(Nrows * sizeof(float));
	float *d_covarianceMatrix;
	float *d_meanmatrix;
	float *h_biaozhuncha = (float*)malloc(sizeof(float)*Nrows);
	float *h_matrix = (float *)malloc(Nrows * Ncols * sizeof(float));
	float *h_matrixtest = (float *)malloc(Nrows * Ncolstest * sizeof(float));
	float *h_Tsquare = (float *)malloc(Ncolstest * sizeof(float));
	float *h_SPE = (float *)malloc(Ncolstest * sizeof(float));
	cudaMalloc(&d_meanmatrix, Nrows*Ncols * sizeof(float));
	Matrixinput(h_matrix, h_matrixtest, Nrows, Ncols, Nrowstest, Ncolstest, zhengchang, ceshi, argv);
	d_covarianceMatrix = covarianceMatrix(h_matrix, d_meanmatrix, h_biaozhuncha, Nrows, Ncols);
	evd(d_covarianceMatrix, h_U, h_S, Nrows, Ncols);
	for (int i = 0; i < Nrows; i++)
	{
		sum = sum + h_S[i];
	}
	for (int i = 0; i < Nrows; i++)
	{
		sum1 = sum1 + h_S[Nrows - 1 - i];
		pNcols++;
		if ((sum1 / sum) > 0.85)
			break;
	}
	tongjiliang(h_U, h_S, h_Tsquare, h_SPE, pNcols, h_matrixtest, d_meanmatrix, h_biaozhuncha, Nrows, Ncols, Ncolstest);
	printf("主元个数p=%d\n", pNcols);
	printf("对角阵\n");
	for (int i = 0; i < pNcols; i++)
		printf("S[%d]=%e\n", i, h_S[Nrows - 1 - i]);
	printf("主元P\n");
	for (int i = 0; i < Nrows; i++)
	{
		for (int j = 0; j < pNcols; j++)
		{
			printf("P[%d,%d]=%e ", i, j, h_U[(Nrows - 1 - j)*Nrows + i]);
			if (j + 1 == pNcols)
				printf("\n");
		}
	}
	FILE *fp3 = fopen("SPE.txt", "w");
	for (int i = 0; i < Ncolstest; i++)
	{
		fprintf(fp3, "%e\n", h_SPE[i]);
	}
	FILE *fp4 = fopen("Tsquare.txt", "w");
	for (int i = 0; i < Ncolstest; i++)
	{
		fprintf(fp4, "%e\n", h_Tsquare[i]);
	}
	fclose(fp3);
	fclose(fp4);
	free(h_U);
	free(h_S);
	free(h_matrix);
	free(h_matrixtest);
	free(h_Tsquare);
	free(h_SPE);
	free(h_biaozhuncha);
	cudaFree(d_meanmatrix);
	endtime = clock();
	printf("程序运行时间：%dms\n", endtime - startime);
	getchar();
	return 0;
}