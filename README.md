# 쿠버네티스 배포와 EFK 모니터링 구축

## 10/11~10/12

- ![image](./img/week1.PNG)

- VPC 환경의 네트워크 인프라 구축
- 이중화된 서브넷 구성
- NAT AMI를 사용한 NAT 인스턴스 생성하여 NAT Gateway를 대체
- Public 서브넷과 Private 서브넷 간 통신 확인 위해 임시로 Private 인스턴스 생성하여 SSH
- ![image](./img/privatessh.PNG)

### 문제점

- NAT 인스턴스에 대한 라우팅을 Private Subnet에 적용하고 보안 그룹 룰을 설정하였으나 Private 인스턴스에서 인터넷을 통한 패키지 매니저 업데이트 실패, Public은 성공
