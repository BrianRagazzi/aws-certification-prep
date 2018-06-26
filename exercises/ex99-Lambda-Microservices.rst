

Derived from https://github.com/aws-samples/aws-microservices-deploy-options#deployment-package-lambda-functions

Prep Ubuntu: needs: curl, nodejs, default-jdk, npm, python-pip, python-dev, build-essential, python-setuptools, maven

sudo apt-get install curl nodejs default-jdk npm python-pip python-dev build-essential python-setuptools maven

pip install --user aws-sam-cli
# OSX and Ubuntu need /bin appended
USER_BASE_PATH=$(python -m site --user-base)/bin
export PATH=$PATH:$USER_BASE_PATH

check
sam --version
npm version

npm install -g aws-sam-local

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
git clone https://github.com/arun-gupta/microservices-greeting
git clone https://github.com/arun-gupta/microservices-name
git clone https://github.com/arun-gupta/microservices-webapp

Test microservices locally with sam cli:

sam local start-api --template microservices-greeting/greeting-sam.yaml --port 3001
The first run will have to download the images and may take a few minutes to complete



