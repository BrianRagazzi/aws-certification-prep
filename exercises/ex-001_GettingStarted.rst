ex-001: Getting started
=======================

Status
------
Version 1.0 (6/18/18)

Dependencies
------------
.. list-table::
   :widths: 25, 25
   :header-rows: 0

   * - Depends on exercise(s)
     - None
   * - Prerequisite for exercise(s)
     - All

Objectives
----------

- Get your local environment ready.
- Create an AWS IAM user that will allow programmatic access to the EC2 API.
- Use **awscli** to briefly explore EC2.
- Familiarize yourself with a couple **awscli** commandline options.

Expected Costs
--------------
The activities in this exercise are NOT expected to result in charges to your AWS account.

Initial
-------
Install **git** and **virtualenv**, if you don't already have them installed. 

- **git** is used to acquire the latest version of this repository
- **virtualenv** is used to to manage Python packages for different projects. Using virtualenv allows you to avoid installing Python packages globally which could break system tools or other projects. You can install virtualenv using pip.
- **jq** is used to parse json data

On Ubuntu, you'll simply run

.. code-block::

	sudo apt-get install git virtualenv jq

Here are the links:

- `virtualenv <https://virtualenv.pypa.io/en/stable/>`_
- `git <https://git-scm.com/>`_
- `jq <https://stedolan.github.io/jq/download/>`

Clone this GitHub repo
----------------------
.. code-block::

	git clone git@github.com:addr2data/aws-certification-prep.git


If you don't have your SSH key(s) added GitHub, you can use HTTP instead.

.. code-block::
	
	git clone https://github.com/addr2data/aws-certification-prep.git

Set up your virtual environment
--------------------------------
These commands set up a virtual environment for isolation of python packages by project and enable python commands from BASH


.. code-block::

 virtualenv aws-certification-prep
 cd aws-certification-prep
 source bin/activate


Install requirements
--------------------
Be sure that your command prompt begins with **(aws-certification-prep)**, which indicates that you are in the correct python virtual environment

.. code-block::

 	pip install boto3 docopt awscli

Set up a user account for API access
------------------------------------
- Login to your AWS account.
- Under Services / Security, Identity & Compliance select **IAM**.
- Select **users**
- Click **Add user**
- Under **Set user details**, enter user name **apiuser01**.
- Under **Select AWS access type**, select **Programmatic access**.  This account does not require AWS Management Console access.
- Click **Next: Permissions**.
- Under **Set permissions for apiuser01**, select **Attach existing policies directly**.
- Search for **AmazonEC2FullAccess**, then select **AmazonEC2FullAccess** (we will add access to other services later).
- Click **Next: Review**.
- Click **Create user**.
- On the following screen, copy the values for **Access key ID** and **Secret access key**.  You'll have to click the **Show** link in order to display teh actual Secret Key value.  Once copied and saved, click **Close**

Create a credentials file
-------------------------
Back on our workstation, we'll set up the tools to automatically authenticate using the account we just set up

.. code-block::

	mkdir ~/.aws
	vi ~/.aws/credentials

Insert the **Access key ID** and **Secret access key** that you copied in the previous step. Save the file.

.. code-block::

	[default]
	aws_access_key_id = YOUR_ACCESS_KEY
	aws_secret_access_key = YOUR_SECRET_KEY

Create a configuration file
---------------------------

.. code-block::

	vi ~/.aws/config

Insert the appropriate region for your location (see the URL where you logged into the AWS Console above.  For example **us-east-2**).

.. code-block::

    [default]
    region = YOUR_REGION
    output = json


Verify access
-------------
Use the following awscli command to verify that you are able to access the EC2 API by attempting to show the EC2 regions.

.. code-block::

	aws ec2 describe-regions

Should return the list of regions formatted in json:

.. code-block::

    {
        "Regions": [
            {
                "Endpoint": "ec2.ap-south-1.amazonaws.com",
                "RegionName": "ap-south-1"
            },
            {
                "Endpoint": "ec2.eu-west-3.amazonaws.com",
                "RegionName": "eu-west-3"
            },
            <--- SNIP --->
            {
                "Endpoint": "ec2.us-west-1.amazonaws.com",
                "RegionName": "us-west-1"
            },
            {
                "Endpoint": "ec2.us-west-2.amazonaws.com",
                "RegionName": "us-west-2"
            }
        ]
    }

Using the **'--dry-run'** option lets you verify access without actually runninng the command. Don't be fooled by the **'An error occurred'** part of the message, the operation was successful.

.. code-block::

    aws ec2 describe-regions --dry-run

Will result in 

.. code-block::

    An error occurred (DryRunOperation) when calling the DescribeRegions operation: Request would have succeeded, but DryRun flag is set.
    
The dry-run option does do anything of value for this command, but later when we issue commands that make changes, it's useful to perform a check before the actual run

Verify restriction
------------------
Use the following awscli command to verify that you NOT are able to access the IAM API

.. code-block::

    aws iam get-account-summary
    
Should result in 

.. code-block::

    An error occurred (AccessDenied) when calling the GetAccountSummary operation: User: arn:aws:iam::926075045128:user/apiuser01 is not authorized to perform: iam:GetAccountSummary on resource: *

This is the expected result since we did not grant our apiuser account permissions to IAM

Formatting output
-----------------
Use the following awscli command with **'--output text'** and **'--output table'** options to see different output formats.

.. code-block::

    aws ec2 describe-regions --output text

Will produce results that look like

.. code-block::

    REGIONS ec2.ap-south-1.amazonaws.com    ap-south-1
    REGIONS ec2.eu-west-3.amazonaws.com eu-west-3

    <--- SNIP --->

    REGIONS ec2.us-west-1.amazonaws.com us-west-1
    REGIONS ec2.us-west-2.amazonaws.com us-west-2

.. code-block::

    aws ec2 describe-regions --output table

Will produce results that look like

.. code-block::

    ----------------------------------------------------------
    |                     DescribeRegions                    |
    +--------------------------------------------------------+
    ||                        Regions                       ||
    |+-----------------------------------+------------------+|
    ||             Endpoint              |   RegionName     ||
    |+-----------------------------------+------------------+|
    ||  ec2.ap-south-1.amazonaws.com     |  ap-south-1      ||
    ||  ec2.eu-west-3.amazonaws.com      |  eu-west-3       ||
    <--- SNIP --->
    ||  ec2.us-west-1.amazonaws.com      |  us-west-1       ||
    ||  ec2.us-west-2.amazonaws.com      |  us-west-2       ||
    |+-----------------------------------+------------------+|

The **--output** options are valuable in overriding the json output option we set as default in the ~/.aws/config file

Filtering results
-----------------
Use the following awscli command with **'--query'** option to filter results.

.. code-block::

    aws ec2 describe-regions --query Regions[*].RegionName

Indicates that only the RegionName value of the Regions set should be return and produces results that look like

.. code-block::

    [
        "ap-south-1",
        "eu-west-3",
         <--- SNIP --->
        "us-west-1",
        "us-west-2"
    ]

Another use of the query subcommand is to return values for only records that match your criteria, for example
.. code-block::

     aws ec2 describe-regions --query 'Regions[?RegionName==`us-east-2`].Endpoint' --output text
     
Indicates that the Endpoint value for the Regions whose RegionName is **us-east-2** is returned in text format, 

.. code-block::

	ec2.us-east-2.amazonaws.com


Explore your Region
-------------------
Use the following awscli command to examine the **Availability Zones** in your region.

.. code-block::

    aws ec2 describe-availability-zones

    {
        "AvailabilityZones": [
            {
                "State": "available",
                "Messages": [],
                "RegionName": "us-east-1",
                "ZoneName": "us-east-1a"
            },
            {
                "State": "available",
                "Messages": [],
                "RegionName": "us-east-1",
                "ZoneName": "us-east-1b"
            },
            {
                "State": "available",
                "Messages": [],
                "RegionName": "us-east-1",
                "ZoneName": "us-east-1c"
            },
            {
                "State": "available",
                "Messages": [],
                "RegionName": "us-east-1",
                "ZoneName": "us-east-1d"
            },
            {
                "State": "available",
                "Messages": [],
                "RegionName": "us-east-1",
                "ZoneName": "us-east-1e"
            },
            {
                "State": "available",
                "Messages": [],
                "RegionName": "us-east-1",
                "ZoneName": "us-east-1f"
            }
        ]
    }

Explore another Region
----------------------
Use the following awscli command to examine the **Availability Zones** in another region.

.. code-block::
    
    aws ec2 describe-availability-zones --region us-east-2

    {
        "AvailabilityZones": [
            {
                "State": "available",
                "Messages": [],
                "RegionName": "us-east-2",
                "ZoneName": "us-east-2a"
            },
            {
                "State": "available",
                "Messages": [],
                "RegionName": "us-east-2",
                "ZoneName": "us-east-2b"
            },
            {
                "State": "available",
                "Messages": [],
                "RegionName": "us-east-2",
                "ZoneName": "us-east-2c"
            }
        ]
    }

Custom scripts
--------------
Run the following script to see all the **Regions** and **Availability Zones** together.

.. code-block::

    python awscertprep_cli.py show_regions --avail_zones

Output from this script should look like 

.. code-block::
    Regions                  Availability Zones
    -------                  ------------------
    ap-northeast-1           (ap-northeast-1a, ap-northeast-1c, ap-northeast-1d)
    ap-northeast-2           (ap-northeast-2a, ap-northeast-2c)
    ap-south-1               (ap-south-1a, ap-south-1b)
    ap-southeast-1           (ap-southeast-1a, ap-southeast-1b, ap-southeast-1c)
    ap-southeast-2           (ap-southeast-2a, ap-southeast-2b, ap-southeast-2c)
    ca-central-1             (ca-central-1a, ca-central-1b)
    eu-central-1             (eu-central-1a, eu-central-1b, eu-central-1c)
    eu-west-1                (eu-west-1a, eu-west-1b, eu-west-1c)region_azs_sh
    eu-west-2                (eu-west-2a, eu-west-2b, eu-west-2c)
    eu-west-3                (eu-west-3a, eu-west-3b, eu-west-3c)
    sa-east-1                (sa-east-1a, sa-east-1c)
    us-east-1                (us-east-1a, us-east-1b, us-east-1c, us-east-1d, us-east-1e, us-east-1f)
    us-east-2                (us-east-2a, us-east-2b, us-east-2c)
    us-west-1                (us-west-1a, us-west-1b)
    us-west-2                (us-west-2a, us-west-2b, us-west-2c)

**BASH and jq option**:  Run this script to produce a list of regions and the Availabilty Zones for each

.. code-block::

	./region_azs.sh

Output from this script should look like 

.. code-block::

	REGION:ap-south-1  AZs:ap-south-1a, ap-south-1b
	REGION:eu-west-3  AZs:eu-west-3a, eu-west-3b, eu-west-3c
	<--- SNIP --->
	REGION:us-west-1  AZs:us-west-1b, us-west-1c
	REGION:us-west-2  AZs:us-west-2a, us-west-2b, us-west-2c




Summary
-------
- You have set up your local environment.
- You have created a IAM user **apiuser01** and gave it programmatic access only.
- You have assigned **apiuser01** full access to the EC2 API.
- You used **awscli** to verify that **apiuser01** has access to the EC2 API.
- You used **awscli** to verify that **apiuser01** does NOT have access to the IAM API.
- You used **awscli** to explore AWS **regions** and **Availability Zones**.
- You experimented with a couple of **awscli** commandline options.

Next steps
----------
Explore VPC concepts in 
`ex-002 <https://github.com/addr2data/aws-certification-prep/blob/master/exercises/ex-002_ExploringVpcs.rst>`_

