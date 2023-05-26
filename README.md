# CloudFormation EKS(fargate) サンプル

EKS(fargate)を使用したargocd,dashbordのdemo環境

## 必要環境

* Bitbucket
    * SSH秘密鍵(repository access)
* k8s
    * kubectl
    * helm
* aws
	* EC2キーペア(sndbox)
    * awscli
	* eksctl
    * rain
	* cfn-lint
* os command
    * make
	* bash
    * jq
    * base64
    * envsubst

## Files

| path                           | desc                             |
|--------------------------------|----------------------------------|
| Makefile                       | コマンド操作ヘルパー             |
| global/valiables.mk            | 共通の環境変数                   |
| stacks_base/                   | VPC用のリソース                  |
| stacks_eks/                    | EKS用のリソース                  |

## Setup

aws-cliの設定。プロファイル作成

```
$ aws configure
```

## Provisioning

一括
```
$ make -C stacks_base deploy
```

個別
```
$ make -C stacks_base/01_network deploy
```

## Usage

* eks context *

aws eks update-kubeconfig --name eks-main --alias eks-main

* dashboard *

http://<ALBのDNS>

「認証なし設定」なので認証画面のskipをクリックするとダッシュボードへ遷移する

* argocd *

http://<ALBのDNS>

[user]
admin
[initial password]
```
$ kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

* sample app *

http://<ALBのDNS>

