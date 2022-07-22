#ifndef SM_SERVER_
#define SM_SERVER_

#define _CRT_SECURE_NO_WARNINGS

#include <stdio.h>
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <stdbool.h>
#include <string.h>
#include <conio.h>
#include <tchar.h>
#include <iostream>
#include <fstream>

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgcodecs.hpp>

using namespace cv;
using namespace std;

typedef struct{
	double	size;
	BYTE	data[218770];		//이미지
} IMAGE_DATA;

IMAGE_DATA* img_smdat;

HANDLE hMemoryMap = NULL;
LPBYTE pMemoryMap = NULL; // LPBYTE는 unsigned char의 포인터형,8bit
TCHAR TEST_SM[] = TEXT("MyFileMappingObject");

void main() {

	hMemoryMap = OpenFileMapping(
		FILE_MAP_ALL_ACCESS,	// read/write access
		FALSE,					// do not inherit the name
		TEST_SM);				// 공유 파일맵의 이름 - Uique 해야한다.

	if (!hMemoryMap) {
		_tprintf(TEXT("Could not open file mapping object (%d).\n"),
			GetLastError());
		//return FALSE;
	}

	pMemoryMap = (LPBYTE)MapViewOfFile(
		hMemoryMap,				// 파일맵의 핸들
		FILE_MAP_ALL_ACCESS,    // 액세스 모드 - 현재는 쓰기
		0,						// 메모리 시작번지부터의 이격된 상위 32비트 
		0,						// 메모리 시작번지부터의 이격된 하위 32비트
		0);						// 사용할 메모리 블록의 크기 - 0이면 설정한 전체 메모리

	if (!pMemoryMap)
	{
		CloseHandle(hMemoryMap);
		printf("COULD NOT OPEN THE SHARED MEMORY\n");
		//return FALSE;
	}
	printf("TEST1 SHARED MEMORY IS CREATED\n");
	
	img_smdat = (IMAGE_DATA*)pMemoryMap;

	// 동적 메모리 할당 : 정확한 데이터 크기만큼의 Matrix 데이터를 만들기 위함
	BYTE* data_buf;
	data_buf = (BYTE*)malloc(sizeof(BYTE) * img_smdat->size);

	for (int i = 0; i < img_smdat->size; i++)
		data_buf[i] = img_smdat->data[i];

	// Byte array to Matrix to Image 변환, imshow로 이미지 확인
	Mat image = Mat(img_smdat->size,1,CV_8U, data_buf);
	Mat pic = imdecode(image, 1);
	imshow("Pic", pic);
	waitKey(0);

	UnmapViewOfFile(pMemoryMap);
	CloseHandle(hMemoryMap);
	//return 0;
}

#endif

