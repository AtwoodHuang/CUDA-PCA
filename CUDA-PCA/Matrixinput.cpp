#include<stdio.h>
void Matrixinput(float*h_matrix, float*h_matrixtest, int Nrows, int Ncols, int Nrowstest, int Ncolstest, bool zhengchang, bool ceshi, char **argv)
{
	FILE*fp;
	FILE*fp1;
	int lines = 0;
	int linestest = 0;
	fp = fopen(argv[1], "r");//打开文件
	if (fp == NULL)//打开失败
		printf("打开失败");
	fp1 = fopen(argv[2], "r");//打开文件
	if (fp1 == NULL)//打开失败
		printf("打开失败");
	if (zhengchang == true)
	{
		while (lines < Nrows)
		{
			for (int i = 0; i < Ncols; i++)
				if (fscanf(fp, "%f", (h_matrix + i*Nrows + lines)) == EOF)
					break;//读取数据
			if (feof(fp))
				break;//判断是否文件结束。
			lines++;//读取一行成功，增加行数。
		}
	}
	else
	{
		while (lines < Ncols)
		{
			for (int i = 0; i < Nrows; i++)
				if (fscanf(fp, "%f", (h_matrix + i + lines*Nrows)) == EOF)
					break;//读取数据
			if (feof(fp))
				break;//判断是否文件结束。
			lines++;//读取一行成功，增加行数。
		}
	}
	if (ceshi == false)
	{
		while (linestest < Ncolstest)
		{
			for (int i = 0; i < Nrows; i++)
				if (fscanf(fp1, "%f", (h_matrixtest + i + linestest*Nrows)) == EOF)
					break;//读取数据
			if (feof(fp1))
				break;//判断是否文件结束。
			linestest++;//读取一行成功，增加行数。
		}
	}
	else
	{
		while (linestest < Nrowstest)
		{
			for (int i = 0; i < Ncolstest; i++)
				if (fscanf(fp1, "%f", (h_matrixtest + i*Nrowstest + linestest)) == EOF)
					break;//读取数据
			if (feof(fp1))
				break;//判断是否文件结束。
			linestest++;//读取一行成功，增加行数。
		}
	}




}