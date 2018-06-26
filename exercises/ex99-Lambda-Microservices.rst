

Derived from https://github.com/aws-samples/aws-microservices-deploy-options#deployment-package-lambda-functions

Prep Ubuntu: needs: curl, default-jdk, python-pip, python-dev, build-essential, python-setuptools, maven

sudo apt-get install curl nodejs default-jdk npm python-pip python-dev build-essential python-setuptools maven

We need nodejs, but installing it from apt seems to get a very old version

curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs

pip install --user aws-sam-cli
# OSX and Ubuntu need /bin appended
USER_BASE_PATH=$(python -m site --user-base)/bin
export PATH=$PATH:$USER_BASE_PATH

check
sam --version
check for version 0.4.0+
npm -v
Check for version 6+
nodejs -v
check for version 10+

sudo npm install -g aws-sam-local

Run this:
sudo update-alternatives --config java
highlight/copy the path returned
Edit /etc/environment
sudo nano /etc/environment
paste this at the bottom:
JAVA_HOME="<path from above>"
<Ctrl+O> to save, <Ctrl+x> to exit

reload
source /etc/environment

mkdir -p apps/lambda
cd apps/lambda
git clone https://github.com/aws-samples/aws-microservices-deploy-options.git
git clone https://github.com/arun-gupta/microservices-greeting
git clone https://github.com/arun-gupta/microservices-name
git clone https://github.com/arun-gupta/microservices-webapp

Test microservices locally with sam cli:

sam local start-api --template microservices-greeting/greeting-sam.yaml --port 3001
The first run will have to download the images and may take a few minutes to complete

Build the deployment package for each microservice
cd microservices-greeting
mvn clean package -Plambda
ln -s greeting-0.zip greeting.zip
cd ../microservices-name
mvn clean package -Plambda
ln -s name-0.zip name.zip
cd ../microservices-webapp
mvn clean package -Plambda
ln -s webapp-0.zip webapp.zip
cd ..
cd /aws-microservices-deploy-options/apps/lambda

IAM, add AmazonS3FullAccess & AWSCloudFormationReadOnlyAccess permissions to apiuser01 account

aws s3api create-bucket --bucket bpr-microservices-test2 \
  --region us-east-2 \
  --create-bucket-configuration LocationConstraint=us-east-2


sam package \
  --template-file sam.yaml \
  --s3-bucket bpr-microservices-test2 \
  --output-template-file \
  sam.transformed.yaml
  
  Results:
  Uploading to f71017c32fdb512ffd4f9ce814f1d7ab  9366742 / 9366742.0  (100.00%)
Successfully packaged artifacts and wrote output template to file sam.transformed.yaml.
Execute the following command to deploy the packaged template
aws cloudformation deploy --template-file /home/build/aws-microservices-deploy-options/apps/lambda/sam.transformed.yaml --stack-name <YOUR STACK NAME>

sam deploy \
  --template-file sam.transformed.yaml \
  --stack-name aws-microservices-deploy-options-lambda \
  --capabilities CAPABILITY_IAM
