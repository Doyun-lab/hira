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


