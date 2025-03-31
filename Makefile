TERRAFORM_DIR=$(CURDIR)/terraform
VARS_FILE=$(CURDIR)/terraform/vars.tfvars

.PHONY: init
init:
	@echo "------Initializing Terraform modules------"
	cd $(TERRAFORM_DIR); terraform init

.PHONY: plan
plan:
	@echo "------Running Terraform plan------"
	cd $(TERRAFORM_DIR); terraform plan --var-file="$(VARS_FILE)"

.PHONY: apply
apply:
	@echo "------Running Terraform apply------"
	cd $(TERRAFORM_DIR); terraform apply --var-file="$(VARS_FILE)" -auto-approve

.PHONY: destroy
destroy:
	@echo "------Running Terraform destroy------"
	cd $(TERRAFORM_DIR); terraform destroy --var-file="$(VARS_FILE)" -auto-approve

.PHONY: output
output:
	@echo "------Showing Terraform outputs------"
	cd $(TERRAFORM_DIR); terraform output
