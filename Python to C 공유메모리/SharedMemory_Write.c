

#include <stdio.h>
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <stdbool.h>
#include <string.h>
#include <tchar.h>

#define UNIT_PI                 (3.14)
#define RUNTIME (double)        (300.0)
#define FREQ    (double)        (20.0)
#define N_data  (unsigned_int)  (RUNTIME*FREQ)

double    iniTime = 0.0;
double    curTime = 0.0;
double    delTime = 0.0;
double    simTime = 0.0;
double    simTime_gps = 0.0;
double    Ts = 1 / FREQ;

double    data1 = 0.0;
double    data2 = 0.0;

int	      num = 0;

int  simCnt = 0;

typedef struct {
	double       data_1;
	double       data_2;
} TEST_DATA;

TCHAR TEST_SM[] = TEXT("test data");

double GetWindowTime(void) {
	LARGE_INTEGER   liCount, liFreq;
	QueryPerformanceCounter(&liCount); // 시간 함수 밀리 세컨드 단위로 측정이 가능하다
	QueryPerformanceFrequency(&liFreq); // 진동수/[sec]
	return((liCount.QuadPart / ((double)(liFreq.QuadPart))) * 1000.0);
};
int main()
{
	HANDLE dMemoryMap = NULL;
	LPBYTE qMemoryMap = NULL; // LPBYTE는 unsigned char의 포인터형

	dMemoryMap = CreateFileMapping(
		INVALID_HANDLE_VALUE, // 파일 맵의 핸들, 초기에 0xffffffff를 설정한다.
		NULL,				// 보안 속성
		PAGE_READWRITE,     // 읽고/쓰기 속성
		0,					// 64비트 어드레스를 사용한다. 상위 32비트 - 메모리의 크기
		sizeof(TEST_DATA),   // 하위 32비트 - 여기선LPBYTE 타입.
		TEST_SM);            // 공유 파일맵의 이름 - Uique 해야한다.

	if (!dMemoryMap) {
		_tprintf(TEXT("Could not open file mapping object (%d).\n"), GetLastError());
		return FALSE;
	}

	qMemoryMap = (BYTE*)MapViewOfFile(
		dMemoryMap,				// 파일맵의 핸들
		FILE_MAP_ALL_ACCESS,    // 액세스 모드 - 현재는 쓰기
		0,						// 메모리 시작번지부터의 이격된 상위 32비트 
		0,						// 메모리 시작번지부터의 이격된 하위 32비트
		0);						// 사용할 메모리 블록의 크기 - 0이면 설정한 전체 메모리

	if (!qMemoryMap)
	{
		CloseHandle(dMemoryMap);
		_tprintf(TEXT("Could not open file mapping object (%d).\n"), GetLastError());
		return FALSE;
	}

	TEST_DATA* test_smdat = (TEST_DATA*)qMemoryMap;

	num = num + 1;
	test_smdat->data_1 = 50;
	test_smdat->data_2 = 100.0;

	printf("%d: %f %f\n", num, test_smdat->data_1,test_smdat->data_2);

	getchar();

	if (qMemoryMap)
		UnmapViewOfFile(qMemoryMap);
	if (dMemoryMap)
		CloseHandle(dMemoryMap);

	return 0;
}
