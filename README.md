# Đề bài
[Đề bài 13: Dịch vụ Lên lịch Đăng bài Mạng xã hội](https://docs.google.com/document/d/1Slv-_sBmwI-i_RHg9si-eywNaMgMku9Cw6iT10O1tWo/edit?tab=t.0)

Ý tưởng: Một ứng dụng SaaS cho phép người dùng kết nối các tài khoản mạng xã hội và lên lịch đăng bài trong tương lai.

Yêu cầu Hệ thống & Chức năng:

- Thành phần chính: ECS Fargate (cho API), EventBridge Scheduler, SQS, Lambda.
- Luồng dữ liệu: Người dùng gọi API (trên ECS) để tạo lịch. API sẽ tạo một lịch trình trên EventBridge Scheduler. Khi đến giờ, EventBridge sẽ gửi message vào SQS. Một hàm Lambda sẽ đọc từ SQS và thực hiện việc đăng bài.
- Tính năng: Lên lịch, sửa, xóa bài đăng.

Yêu cầu Vận hành & Mở rộng:

- Các token truy cập mạng xã hội phải được mã hóa và lưu trữ an toàn trong Secrets Manager.
- Giám sát số lượng lịch trình đang hoạt động và tỷ lệ đăng bài thành công/thất bại.

# Sơ đồ kiến trúc và luồng dữ liệu

```
[User / Cron UI]
       |
       | (1) Call API via HTTPS
       v
[ALB (public)]
       |
       v
[ECS (Fargate) - API tạo lịch]
       |
       | (2) Gọi EventBridge để tạo lịch
       v
[EventBridge Scheduler]
       |
       | (3) Đến giờ -> gửi message
       v
[SQS Queue]
       |
       | (4) Trigger Lambda
       v
[Lambda Function]
       |
       | (5) Đọc Secrets / Ghi DB
       |      |
       |      v
       |   [Secrets Manager]
       |   [DynamoDB]
       |
       | (6) Gọi API mạng xã hội
       v
[External API / Social Media]
```

# Cấu trúc project

```
aws/
├── Makefile
├── pre-build.sh
├── create-aws-sts.sh
├── README.md
└── terraform/
    └── envs/
        └── dev/
            ├── _variables.tf
            ├── terraform.dev.tfvars
            ├── 1.general
            │   ├── _backend.tf
            │   ├── _data.tf
            │   ├── _output.tf
            │   ├── _variables.tf
            │   ├── alb.tf
            │   ├── ecs.tf
            │   ├── eventbridge.tf
            │   ├── iam.tf
            │   ├── lambda.tf
            │   ├── secrets.tf
            │   ├── security_groups.tf
            │   ├── sqs.tf
            │   └──vpc.tf
            │
            ├── 3.database
            │   ├── _backend.tf
            │   ├── _output.tf
            │   ├── _variables.tf
            │   └── dynamodb.tf
            │
            └── 5.monitoring
                ├── _backend.tf
                ├── _variables.tf
                ├── alarms.tf
                └── cloudwatch.tf
```

**1. Database (3.database) - Nền tảng dữ liệu cho các service khác**

- Chứa Terraform module cho DynamoDB
- Dùng để lưu trạng thái hoặc dữ liệu liên quan đến lịch trình
- Đây là nền tảng dữ liệu cho các service khác

**2. General (1.general) - Core infrastructure để ứng dụng chạy**

Chứa các resource chính của ứng dụng:
  - VPC, Security Groups, ECS cluster → để chạy API container
  - IAM, Lambda, SQS, EventBridge → phục vụ luồng xử lý lịch
  - ALB (Application Load Balancer) → public endpoint cho API

**3. Monitoring (5.monitoring) - Service giám sát và alert**

- Chứa CloudWatch và alarm resources
- Giám sát ECS, Lambda báo lỗi, cảnh báo khi có sự cố

# Setup

## 1. Cài đặt Git

```
# Ubuntu/Debian
sudo apt update && sudo apt install -y git

# MacOS
brew install git

# Kiểm tra cài đặt
git --version
```

## 2. Cài đặt Terraform

```
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# MacOS
brew install terraform

# Kiểm tra cài đặt
terraform --version
```

## 3. Cài đặt AWS CLI

```
# Ubuntu/Debian
sudo apt install -y awscli

# MacOS
brew install awscli

# Kiểm tra cài đặt
aws --version
```

## 4. Cài đặt Make

```
# Ubuntu/Debian
sudo apt install -y make

# MacOS
brew install make

# Kiểm tra cài đặt
make --version
```

## 5. Clone repository

```
git clone git@github.com:hanhdt-1783/devops-training.git

# Đổi tên project
mv devops-training your-project-name
```

## 6. Tạo AWS Account và IAM User

- Tạo AWS Account (Nếu bạn đã có AWS Account, có thể bỏ qua)
- Tạo IAM User với Username `terraform-user`, Permissions `AdministratorAccess`. Lưu lại Access Key ID + Secret Access Key

## 7. Thiết lập MFA

- Thiết lập MFA với MFA device name là `terraform-user`

## 8. Tạo profile

### Tạo profile chính

```
aws configure --profile your-project-name-default

# Nhập thông tin:
# AWS Access Key ID: (từ Bước 6)
# AWS Secret Access Key: (từ Bước 6)
# Default region: `ap-northeast-1`
# Default output format: `json`
```

### Tạo profile tạm thời

Thêm nội dung sau vào cuối file `~/.aws/credentials`

```
[your-project-name-dev]
aws_access_key_id =
aws_secret_access_key =
aws_session_token =
```

Thêm nội dung sau vào cuối file `~/.aws/config`

```
[your-project-name-dev]
output = json
region = ap-northeast-1
```

Tạo temporary credentials:

```
cd aws
chmod +x create-aws-sts.sh

# Chạy script
./create-aws-sts.sh your-project-name-default your-project-name-dev <account-id> <iam-username> <mfa-token>

# Tham số:
# account-id: AWS Account ID (12 chữ số)
# mfa-token: Mã 6 số từ MFA app
```

## 9. Khởi tạo backend và state management

```
cd aws
chmod +x pre-build.sh
./pre-build.sh

# Nhập thông tin:
# Project Name: your-project-name
# ENV: dev
# Region: ap-northeast-1
```

Update các file `_backend.tf`

```
profile = "your-project-name-dev"
bucket = "your-project-name-dev-iac-state"
kms_key_id = "arn:aws:kms:ap-northeast-1:123456789012:key/abc-def-ghi" # trả ra ở lệnh trên
dynamodb_table = "your-project-name-dev-terraform-state-lock"
```

## 10. Triển khai infrastructure

Tạo file `aws/terraform/envs/dev/terraform.dev.tfvars`

```
project = "your-project-name-dev"
env     = "dev"
region  = "ap-northeast-1"
```

Tạo symlinks cho variables

```
cd aws
make symlink e=dev s=database
make symlink e=dev s=general
make symlink e=dev s=monitoring
```

Initialize, Plan, Apply các services theo thứ tự database -> general -> monitoring

```
cd aws
make init e=dev s=database
make plan e=dev s=database
make apply e=dev s=database

cd aws
make init e=dev s=general
make plan e=dev s=general
make apply e=dev s=general

cd aws
make init e=dev s=monitoring
make plan e=dev s=monitoring
make apply e=dev s=monitoring
```
