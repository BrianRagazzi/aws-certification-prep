ex-005: Getting Started with CloudFormation
===========================================

Status
------
Draft (once the draft has been completed, a version number and date will be provided)

Dependencies
------------
.. list-table::
   :widths: 25, 25
   :header-rows: 0

   * - Depends on exercise(s)
     - ex-001
   * - Prerequisite for exercise(s)
     - tbd

Objectives
----------

    - Learn how CloudFormation Templates are constructed using YAML.
    - Create a Stack in CloudFormation from a Template that mimics the configuration from ex-003 and ex-004.

**Note: Going forward, CloudFormation will allow us to quickly spin up a 'starting configuration' at the beginning of an exercise and delete it at the end. This will allow us to minimize costs without having to rebuild configurations by hand.**   

Expected Costs
--------------
The activities in this exercise may result in charges to your AWS account.

.. list-table::
   :widths: 20, 40, 50
   :header-rows: 1

   * - Component
     - Applicable Costs
     - Notes
   * - CloudFormation
     - None
     - There is no charge for CloudFormation itself, only for the resources that you deploy with it.
   * - VPC (including Subnets, Route Tables and Internet Gateways)
     - None
     - 
   * - Key Pairs
     - None
     - 
   * - Security Groups
     - None
     -
   * - On-demand Instances
     - 
        + $0.0116 per hour per Instance (t2.micro)
     - During this exercise we will be launching two Instances, using ami-a4dc46db (Ubuntu Server 16.04 LTS), which is 'Free tier eligible'. It is not expected that these Instances will need to be running for more than one hour. 
   * - Elastic IPs
     - 
        + $0.00 per hour per EIP that is associated to a running Instance
        + $0.05 per hour per EIP that is NOT associated to a running Instance
     - Unlike ex-004, there will not be periods of time where an EIP is not associated with an running Instance.
   * - Elastic IPs
     - 
        + $0.00 per EIP address remap for the first 100 remaps per month.
        + $0.10 per EIP address remap for additional remaps over 100 per month
     - Unlike ex-004, we will not be re-mapping EIPs.

Add CloudFormation API access to user 'apiuser01' 
-------------------------------------------------
- Login to your AWS account.
- Under services select **IAM**.

Create a policy
~~~~~~~~~~~~~~~

- Select **Policies**.
- Click **Create policy**.
- Under **Service**, click on the **Choose a service** link.
- In the search box, type **CloudFormation**, the select **CloudFormation**.
- Under **Manual actions**, check the box for **All CloudFormation actions**.
- Click on the **Resources** section to expand it.
- Select **All resources**.
- Click on **Review policy**.
- In the name box, type **CloudFormationFullAccess**.
- Click **Create policy**.

Add permissions to 'apiuser01'
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Select **Users**
- Click on **apiuser01**
- Under **Add permissions to admin01**, select **Attach existing policies directly**.
- In the search box, type **CloudFormationFullAccess**, then select **CloudFormationFullAccess**.
- Click on **Next: Review**.
- Click **Add permissions**.

Verify access
-------------
Use the following awscli command to verify access to CloudFormation API.

.. code-block::

	aws cloudformation describe-stacks

	{
		"Stacks": []
	}

View account limits
-------------------
Use the following awscli command to view your account limits for CloudFormation.

For more information on CloudFormation account limits:
`CloudFormation limits <https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cloudformation-limits.html>`_


.. code-block::

	aws cloudformation describe-account-limits
	
	{
		"AccountLimits": [
			{
            	"Name": "StackLimit",
            	"Value": 200
        	},
        	{
            	"Name": "StackOutputsLimit",
            	"Value": 60
        	}
		]
	}

Review the template
-------------------
Below is the contents of the **'ex-005_template.yaml'** file from the **'templates'** directory.

``Notice how '!Ref' is used to reference other resources where needed.``

.. code-block::

	---

	Resources:
	  VPC:
	    Type: AWS::EC2::VPC
	    Properties: 
	      CidrBlock: 10.0.0.0/16
	      Tags:
	        - Key: Name
	          Value: vpc_ex005

	  InternetGateway:
	    Type: AWS::EC2::InternetGateway
	    Properties: 
	      Tags:
	        - Key: Name
	          Value: ig_ex005

	  AttachInternetGateway:
	    Type: AWS::EC2::VPCGatewayAttachment
	    Properties: 
	      InternetGatewayId: !Ref InternetGateway
	      VpcId: !Ref VPC

	  RouteTable:
	    Type: AWS::EC2::RouteTable
	    Properties: 
	      VpcId: !Ref VPC
	      Tags:
	        - Key: Name
	          Value: rtb_pub_ex005

	  DefaultRoute:
	    Type: AWS::EC2::Route
	    Properties: 
	      DestinationCidrBlock: 0.0.0.0/0
	      GatewayId: !Ref InternetGateway
	      RouteTableId: !Ref RouteTable

	  SubnetPublic:
	    Type: AWS::EC2::Subnet
	    Properties:
	      CidrBlock: 10.0.0.0/23
	      Tags:
	        - Key: Name
	          Value: sub_pub_ex005
	      VpcId: !Ref VPC
	  
	  SubnetPrivate:
	    Type: AWS::EC2::Subnet
	    Properties:
	      CidrBlock: 10.0.2.0/23
	      Tags:
	        - Key: Name
	          Value: sub_pri_ex005
	      VpcId: !Ref VPC

	  AssociateSubnetRouteTable:
	    Type: AWS::EC2::SubnetRouteTableAssociation
	    Properties: 
	      RouteTableId: !Ref RouteTable
	      SubnetId: !Ref SubnetPublic

	  SecurityGroup:
	    Type: AWS::EC2::SecurityGroup
	    Properties: 
	      GroupName: sg_ex005
	      GroupDescription: "Security Group for ex-005"
	      SecurityGroupIngress:
	        - 
	          CidrIp: 0.0.0.0/0
	          IpProtocol: tcp
	          FromPort: 22
	          ToPort: 22
	        - 
	          CidrIp: 0.0.0.0/0
	          IpProtocol: icmp
	          FromPort: -1
	          ToPort: -1
	      VpcId: !Ref VPC

	  PublicInstance:
	    Type: AWS::EC2::Instance
	    Properties: 
	      ImageId: ami-a4dc46db
	      InstanceType: t2.micro
	      KeyName: acpkey1
	      SecurityGroupIds: 
	        - !Ref SecurityGroup
	      SubnetId: !Ref SubnetPublic
	      Tags: 
	        - Key: Name
	          Value: i_pub_ex005

	  PrivateInstance:
	    Type: AWS::EC2::Instance
	    Properties: 
	      ImageId: ami-a4dc46db
	      InstanceType: t2.micro
	      KeyName: acpkey1
	      SecurityGroupIds: 
	        - !Ref SecurityGroup
	      SubnetId: !Ref SubnetPrivate
	      Tags: 
	        - Key: Name
	          Value: i_pri_ex005

	  FloatingIpAddress:
	    Type: "AWS::EC2::EIP"
	    Properties:
	      InstanceId: !Ref PublicInstance
	      Domain: vpc

	...

Validate template
-----------------
Use the following awscli command to validate the structure of the template file.

.. code-block::

	aws-cert-prep addr2data$ aws cloudformation validate-template --template-body file://./templates/ex-005_template.yaml

	{
    	"Parameters": []
	}

Template summary
----------------
Use the following awscli command to get a summary of the template.

.. code-block::

	aws cloudformation get-template-summary --template-body file://./templates/ex-005_template.yaml

	{
    	"Parameters": [],
    	"ResourceTypes": [
        	"AWS::EC2::InternetGateway",
        	"AWS::EC2::VPC",
        	"AWS::EC2::RouteTable",
        	"AWS::EC2::VPCGatewayAttachment",
        	"AWS::EC2::Subnet",
        	"AWS::EC2::SecurityGroup",
        	"AWS::EC2::Subnet",
        	"AWS::EC2::Route",
        	"AWS::EC2::SubnetRouteTableAssociation",
        	"AWS::EC2::Instance",
        	"AWS::EC2::Instance",
        	"AWS::EC2::EIP"
    	],
    	"Version": "2010-09-09"
	}

Estimated costs 
---------------
Use the following awscli command to get an estimated monthly cost for the components in the template.

.. code-block::
	
	aws cloudformation estimate-template-cost --template-body file://./templates/ex-005_template.yaml

	{
    	"Url": "http://calculator.s3.amazonaws.com/calc5.html?key=cloudformation/4fd01c4d-7530-4462-a0c3-608cb6df057d"
	}

Create Stack
------------
Use the following awscli command to create a new **'Stack'** based on the template.

.. code-block::

	aws cloudformation create-stack --stack-name ex-005 --template-body file://./templates/ex-005_template.yaml

	{
    	"StackId": "arn:aws:cloudformation:us-east-1:xxxxxxxxxxxx:stack/ex-005/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
	}

Check the status
----------------
Use the following awscli command to check the **'StackStatus'**.

Rerun this command until **'StackStatus'** is **'CREATE_COMPLETE'**.

.. code-block::

	aws cloudformation describe-stacks --stack-name ex-005

	{
    	"Stacks": [
        	{
            	"StackId": "arn:aws:cloudformation:us-east-1:xxxxxxxxxxxx:stack/ex-005/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
            	"StackName": "ex-005",
            	"CreationTime": "2018-06-17T21:47:13.883Z",
            	"RollbackConfiguration": {},
            	"StackStatus": "CREATE_IN_PROGRESS",
            	"DisableRollback": false,
            	"NotificationARNs": [],
            	"Tags": [],
            	"EnableTerminationProtection": false
        	}
    	]
	}

Review the events
-----------------
Use the following awscli command to check the **StackEvents**.

.. code-block::

	aws cloudformation describe-stack-events --stack-name ex-005

	... not included do to size ...

Kill the Stack (if not planning to complete ex-006 immediately)
---------------------------------------------------------------
Use the following awscli command to delete the Stack.

.. code-block::

	aws cloudformation delete-stack --stack-name ex-005

	... not included do to size ...

Check the status
----------------
Use the following awscli command to check the **'StackStatus'**.

Rerun this until you get the following error: "An error occurred (ValidationError) when calling the DescribeStacks operation: Stack with id ex-005 does not exist"

.. code-block::

	aws cloudformation describe-stacks --stack-name ex-005

	{
    	"Stacks": [
        	{
            	"StackId": "arn:aws:cloudformation:us-east-1:926075045128:stack/ex-005/fef146e0-7277-11e8-a610-50d5ca63261e",
            	"StackName": "ex-005",
            	"CreationTime": "2018-06-17T21:47:13.883Z",
            	"DeletionTime": "2018-06-17T23:25:39.791Z",
            	"RollbackConfiguration": {},
            	"StackStatus": "DELETE_IN_PROGRESS",
            	"DisableRollback": false,
            	"NotificationARNs": [],
            	"Tags": [],
            	"EnableTerminationProtection": false
        	}
    	]
	}

Summary
-------
- We created a Key Pair.
- We created a Security Group.
- We added rules to the Security Group.
- We create two Instances.
- We allocated a Elastic IP.
- We map/re-mapped that Elastic IP to Instances.
- We tested connectivity to/from both the 'public' and 'private' Instances.

Next steps
----------
In ex-005, we will recreate the configuration built in ex-003 andd ex-004, using CloudFormation.
















