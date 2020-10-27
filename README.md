# HIRA (건강보험심사평가원) 산・학・관 교육

- Period : 2020.07.22 ~ 2020.09.03  
- Subject : How does a Particular Drug affect Stroke Complications? (Development of Classification Model)
- Language : SAS, SQL, R
- Model : XGBoost, Random Forest, Logistic Regression

## Data Introduction
- T200, T300, T400, T530 테이블을 이용하여 '약품 사용에 따른 뇌졸중 합병증을 예측하는 분류 모델' 생성  
  
> T200 : 명세서 일반 내역  
> T300 : 진료 내역  
> T400 : 상병 내역  
> T530 : 원외처방 내역

위의 Data Table을 조합 > 환자별로 성별, 나이, 복용일, 평균복용량, 약품사용여부 (사용 : 1, 미사용 : 0), 합병증 여부(Target)으로 Data set 생성  

## Topic
- 뇌혈관 질환 환자에게 예후가 좋은 약품이 실제로 많이 처방 되지않고 있는데, 이러한 약품들을 복용했을 때 예후가 좋은 것을 입증하는 것이 목표
- 뇌졸중은 의료 기관간 편차가 크며 사망률과 입원일 수도 요양기관간에 차이가 큰 것으로 나타남  

## Data Analysis
- Target 주상병 코드
> [I636] : 대뇌정맥 혈전증에 의한 비화농성 뇌경색증  
> [I676] : 두개내정맥계통의 비화농성 혈전증  
> [O225] : 임신중 대뇌정맥혈전증  
> [O873] : 산후기중 대뇌정맥혈전증  

- 분석 과제
> I60, I61, I62이 주.부상병 3번째까지 들어가 발생하여 동반되었는지 조사  

- 최종 목표
> 사용한 약품과 다양한 Feature에 따라서 합병증이 발생 여부를 예측하는 분류 모델 개발
