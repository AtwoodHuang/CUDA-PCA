#include<stdio.h>
void Matrixinput(float*h_matrix, float*h_matrixtest, int Nrows, int Ncols, int Nrowstest, int Ncolstest, bool zhengchang, bool ceshi, char **argv)
{
	FILE*fp;
	FILE*fp1;
	int lines = 0;
	int linestest = 0;
	fp = fopen(argv[1], "r");//���ļ�
	if (fp == NULL)//��ʧ��
		printf("��ʧ��");
	fp1 = fopen(argv[2], "r");//���ļ�
	if (fp1 == NULL)//��ʧ��
		printf("��ʧ��");
	if (zhengchang == true)
	{
		while (lines < Nrows)
		{
			for (int i = 0; i < Ncols; i++)
				if (fscanf(fp, "%f", (h_matrix + i*Nrows + lines)) == EOF)
					break;//��ȡ����
			if (feof(fp))
				break;//�ж��Ƿ��ļ�������
			lines++;//��ȡһ�гɹ�������������
		}
	}
	else
	{
		while (lines < Ncols)
		{
			for (int i = 0; i < Nrows; i++)
				if (fscanf(fp, "%f", (h_matrix + i + lines*Nrows)) == EOF)
					break;//��ȡ����
			if (feof(fp))
				break;//�ж��Ƿ��ļ�������
			lines++;//��ȡһ�гɹ�������������
		}
	}
	if (ceshi == false)
	{
		while (linestest < Ncolstest)
		{
			for (int i = 0; i < Nrows; i++)
				if (fscanf(fp1, "%f", (h_matrixtest + i + linestest*Nrows)) == EOF)
					break;//��ȡ����
			if (feof(fp1))
				break;//�ж��Ƿ��ļ�������
			linestest++;//��ȡһ�гɹ�������������
		}
	}
	else
	{
		while (linestest < Nrowstest)
		{
			for (int i = 0; i < Ncolstest; i++)
				if (fscanf(fp1, "%f", (h_matrixtest + i*Nrowstest + linestest)) == EOF)
					break;//��ȡ����
			if (feof(fp1))
				break;//�ж��Ƿ��ļ�������
			linestest++;//��ȡһ�гɹ�������������
		}
	}




}