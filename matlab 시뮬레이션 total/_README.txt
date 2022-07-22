[Global Guidance MATLAB Simulation]

*****측정 오차***** 
- GPS : Novatel 기준 
- IMU : Xsens Mti-630 기준 = 1[deg] RMS 

*****최대 조향각*****
- ERP42 물리적 최대 조향각 : 28 [deg/sec]

*****모터 전달함수*****
- 조향 제어 모터
: 1차 모델로 근사함. Gain 값은 1
: 시정수 Tau 값 : 0.1 [sec]
- 속력 제어 모터
: 1차 모델로 근사함. Gain 값은 1
: 시정수 Tau 값 : 1[sec]

속력 제어 모터는 응답속도를 비교적 빠르게, 
조향 제어 모터는 응답속도를 비교적 느리게 설정함.
(조향제어 모터의 응답 속도를 빠르게 하게 되면 시뮬레이션에서 
헤딩이 WayPoint를 향하지 않게 되는 문제가 생겼음)

*****차량 조향각 freeze*****
- 차량이 waypoint과 가까워지면 oscilation 현상 발생
- 현재 freeze distance = 3[m]
- Waypoint과 vehicle 사이의 거리가 freeze distance보다 작을 때 차량 조향각 고정

