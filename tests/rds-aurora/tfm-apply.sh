###############
## FUNCTIONS ##
###############
logKeyValuePair()
{
    echo "    $1: $2"
}
logWarning()
{
    echo "    WARNING -> $1"
}
logAction()
{
    echo ""
    echo "$1 ..."
}

############
## SCRIPT ##
############
set -e
export AWS_DEFAULT_REGION=$AWS_REGION
export AWS_ACCOUNT_ID=$ACCOUNT_ID_DEV_INFRA
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_TFM
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY_TFM

WKDIR=$PWD
group=$(echo "$1"|tr '/' '-')
logAction "rds aurora - APPLYING"
logKeyValuePair "group" $group 
cd "$WKDIR/tests/rds-aurora"

# BACKEND-S3
backend="backend.tf"
echo "terraform {" >> backend
echo "  backend \"s3\" {" >> backend
echo "    bucket = \"artifacts-ohpen-215333367418-eu-west-1\"" >> backend
echo "    key    = \"terraform-states/$group\"" >> backend
echo "    region = \"eu-west-1\"" >> backend
echo "  }" >> backend
echo "}" >> backend
cat backend

# TFVARS
tfvars="terraform.tfvars.json"
echo "{" >> $tfvars
echo "    \"group\": \"$group\"" >> $tfvars
echo "}" >> $tfvars
cat $tfvars

terraform init
terraform apply -auto-approve
cd "$WKDIR"