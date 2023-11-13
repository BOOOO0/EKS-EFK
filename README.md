# 쿠버네티스 배포와 EFK 모니터링 구축

<details><summary>NAT 인스턴스 생성</summary>

<div markdown="1">

## 10/11~10/12

- ![image](./img/week1.PNG)

- 정책 코드를 적용한 IAM 계정 Terraform을 사용해서 생성
- VPC 환경의 네트워크 인프라 구축
- 이중화된 서브넷 구성 (위 그림엔 생략)
- NAT AMI를 사용한 NAT 인스턴스 생성하여 NAT Gateway를 대체
- Public 서브넷과 Private 서브넷 간 통신 확인 위해 임시로 Private 인스턴스 생성하여 SSH
- ![image](./img/privatessh.PNG)

### 문제점

- NAT 인스턴스에 대한 라우팅을 Private Subnet에 적용하고 보안 그룹 룰을 설정하였으나 Private 인스턴스에서 인터넷을 통한 패키지 매니저 업데이트 실패, Public은 성공

### 원인과 해결

- 원인은 NAT 인스턴스의 보안 그룹에서 NAT 인스턴스를 통해 통신하는 인스턴스의 ip 대역에 대한 ingress 룰을 허용하지 않은 것

- ingress 룰 수정으로 해결

- ![image](./img/natworks.PNG)

</div>

</details>

<details><summary>EKS 클러스터 구성, Nginx 배포</summary>

<div markdown="1">

## 10/29

- EKS 클러스터 구성
  - kubectl 설치
  - eksctl 설치
  - eksctl 명령어를 통해 AWS EKS 클러스터 구축
- YAML 스크립트 사용해서 Nginx 배포를 위한 Pod 생성

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  selector:
    matchLabels:
      run: my-nginx
  replicas: 2
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
        - name: my-nginx
          image: nginx
          ports:
            - containerPort: 80
```

- YAML 스크립트 사용해서 Nginx 서비스 실행

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-nginx
  labels:
    run: my-nginx
spec:
  ports:
    - port: 80
      protocol: TCP
  selector:
    run: my-nginx
  type: LoadBalancer
```

- ![image](./img/deploynginx.PNG)

- Nginx 배포 확인

### 의문점

- ![image](./img/getservice.PNG)

- 기존에 구성했던 서브넷과 다른 별도의 서브넷에 노드가 생성된 것으로 보이는데 미리 구성해둔 서브넷에 노드 생성이 가능한지

- 위와 같은 상태라면 전체 아키텍처는 어떻게 되어 있는지

- Private Subnet에 노드가 생성되었다면 어떻게 외부 접속으로 Nginx 배포를 확인할 수 있는지

- 위 궁금증의 답이 로드밸런서의 사용이라면 로드밸런서가 어떤 역할(어떤 원리로)을 해서인지

### 해결

- 우선 eksctl을 사용해서 클러스터를 생성할 경우 전혀 다른 새로운 VPC 환경에 클러스터를 생성하게 된다.

- ![image](./img/createeksctl.PNG)

- 현재 전체 아키텍처는 위와 같으며 기존에 구축한 네트워크 인프라 내에서 생성하려면 클러스터 생성시 yaml 파일을 아래와 같이 작성한 후 `eksctl create cluster -f [파일명].yaml`로 생성할 수 있다.

```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: mission-cluster
  region: ap-northeast-2

vpc:
  subnets:
    private:
      ap-northeast-2a: { id: PrivatesubnetAid }
      ap-northeast-2c: { id: PrivatesubnetBid }

nodeGroups:
  - name: mission-wn
    labels: { role: workers }
    instanceType: t3.medium
    desiredCapacity: 1
    privateNetworking: true
    volumeSize: 4
    ssh:
      allow: true
```

- 외부에서 접속이 가능한 이유는 쿠버네티스의 Service라는 오브젝트 때문이다. 이 Service는 타입을 설정할 수 있는데 그 타입 중 로드밸런서 타입으로 생성할 경우 이 Service가 외부와 통신하며 트래픽을 private subnet에 있는 Pod로 전달해준다.

- 로드밸런서의 사용으로 이전에 생겼던 public <-> private간 네트워크 통신 문제를 해결할 수 있을 것 같고 쿠버네티스는 그동안 마주해오던 문제들의 해결법을 기능으로 갖추고 있는 느낌을 준다.

</div>

</details>

<details><summary>EFK 모니터링 구축, 로그 시각화 확인</summary>

<div markdown="1">

## 11/12

- Fluentbit가 로그를 수집하면 ElasticSearch가 로그를 저장하고 Kibana가 로그를 시각화한다.

- ![image](./img/elasticsearch.PNG)

- ![image](./img/logs.PNG)

### 로드밸런서의 역할

- 로드밸런서를 단순히 부하분산의 용도로 생각했다. 물론 이것도 부하분산이 목적이긴 하지만 이전에 Nginx를 사용해서 배포된 WS에서 리버스 프록시를 하려고 했던 것을 쿠버네티스 서비스로 배포된 Nginx 서비스를 로드밸런서 타입으로 배포해서 가능하게 할 수 있다.

- 그리고 다른 쿠버네티스 서비스를 NodePort 타입으로 배포할 경우 위에서 배포된 Nginx 서비스의 로드밸런서를 통해 특정 포트로 들어오는 트래픽을 받을 수 있다.

- ![image](./img/clb.PNG)

- 위 그림처럼 Nginx 로드밸런서의 External-IP의 9200번 포트로 들어오는 트래픽을 ElasticSearch의 Pod로 전달하도록 할 수 있다.

- ![image](./img/3tier.png)

- 위와 같은 3-티어 아키텍처를 설계할 때 로드밸런서를 활용할 수 있다.

</div>

</details>
