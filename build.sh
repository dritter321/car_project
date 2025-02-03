cd ./lambda
zip lambda_function.zip lambda_function.py
cd ..
aws configure
terraform init
terraform destroy -auto-approve
terraform plan
terraform apply -auto-approve