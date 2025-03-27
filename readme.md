
# High Availability 3-Tier Application

## Overview
This Terraform-managed architecture is designed for a **highly available and scalable** 3-tier web application on AWS. It includes **web, application, and database layers**, ensuring redundancy and security.

## Architecture Diagram
![Architecture Diagram](https://raw.githubusercontent.com/Devblaise/High-availability-3-tier-Web-App/refs/heads/main/images/high_availablity_3_tier_app.drawio_.png)

## Architecture Components
### **Networking & Security**
- **VPC**: Provides network isolation.
- **Public Subnets**: Host the NAT Gateways and the Application Load Balancer.
- **Private Subnets**: Securely host Web Servers, RDS databases, and EFS storage.
- **NAT Gateway**: Allows outbound internet access for instances in private subnets.
- **Security Groups & IAM Roles**: Ensure secure access control.

### **Compute & Scaling**
- **Web Servers (EC2 Instances)**: Hosted in private subnets and deployed in multiple **Availability Zones (AZs)** for fault tolerance.
- **Auto Scaling**: Dynamically adjusts the number of web servers based on demand.
- **Application Load Balancer (ALB)**: Distributes traffic across web servers to ensure high availability.

### **Database Layer**
- **Amazon RDS (Master & Standby DBs)**: Provides a **highly available, managed relational database** with automatic failover.
- **DynamoDB**: Used for highly scalable NoSQL storage.
- **Amazon EFS**: Shared storage for the web servers to maintain state consistency.
- **AWS Elastic Connect**: Used to establish a **secure and high-performance** connection to the database, reducing latency and improving reliability.

### **Security & Secrets Management**
- **Secrets Manager**: Securely stores and retrieves sensitive data such as database credentials.
- **IAM Roles**: Provide secure, least-privilege access to AWS resources.

### **Distributing Traffic: Application Load Balancer**
Configure an Application Load Balancer (ALB) to route internet traffic to EC2 instances running WordPress.
- **Listeners**: HTTP and HTTPS for secure connections. sensitive data such as database credentials.
- **Target Group**: EC2 instances to receive traffic from the ALB.

## Workflow
1. **Users & Admins** access the application via the **Application Load Balancer**.
2. Requests are routed to web servers in private subnets through **Auto Scaling**.
3. Web servers communicate with the **RDS database (Master/Standby)** and **DynamoDB** for data storage using **AWS Elastic Connect**.
4. Shared files are stored in **Amazon EFS** for persistence.
5. Admins access the system securely via IAM roles and **Secrets Manager**.

## Scaling Up: Auto Scaling Group
To handle fluctuating traffic, we’ll create an Auto Scaling Group (ASG). Using a Launch Template, new instances automatically mount EFS and start necessary services. This setup ensures resilience and adaptability. Here is the auto-scaling launch template **userdata script**:
```sh
#!/bin/bash

# update the software packages on the ec2 instance 
sudo yum update -y

# install the apache web server, enable it to start on boot, and then start the server immediately
sudo yum install -y git httpd
sudo systemctl enable httpd 
sudo systemctl start httpd

# install php 8 along with several necessary extensions for wordpress to run
sudo yum install -y \
php \
php-cli \
php-cgi \
php-curl \
php-mbstring \
php-gd \
php-mysqlnd \
php-gettext \
php-json \
php-xml \
php-fpm \
php-intl \
php-zip \
php-bcmath \
php-ctype \
php-fileinfo \
php-openssl \
php-pdo \
php-tokenizer

# Install Mysql-Client 
sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm 
sudo dnf install mysql80-community-release-el9-1.noarch.rpm -y
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
sudo dnf repolist enabled | grep "mysql.*-community.*"
sudo dnf install -y mysql-community-server 

# start and enable the mysql server
sudo systemctl start mysqld
sudo systemctl enable mysqld

# environment variable
EFS_DNS_NAME=fs-01704dc00d1777aa3.efs.eu-west-2.amazonaws.com

# mount the efs to the html directory 
echo "$EFS_DNS_NAME:/ /var/www/html nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" | sudo tee -a /etc/fstab
sudo mount -a

# set permissions
sudo chown apache:apache -R /var/www/html
sudo chmod 755 -R /var/www/html

# restart the webserver
sudo systemctl restart httpd
sudo systemctl restart php-fpm
   ```

## Deployment Instructions
1. **Initialize Terraform:**
   ```sh
   terraform init
   ```
2. **Plan Deployment:**
   ```sh
   terraform plan
   ```
3. **Apply Terraform Configuration:**
   ```sh
   terraform apply -auto-approve
   ```
4. **Destroy Deployment:**
   ```sh
   terraform destroy -auto-approve
   ```
🚀
