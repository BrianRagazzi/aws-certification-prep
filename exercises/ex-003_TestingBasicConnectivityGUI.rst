ex-003: Testing basic connectivity from the AWS Management Console
==================================

Status
------
Version 1.0 (6/28/18)

Dependencies
------------
.. list-table::
   :widths: 25, 25
   :header-rows: 0

   * - Depends on exercise(s)
     - ex-001, ex-002
   * - Prerequisite for exercise(s)
     - None

Objectives
----------
- Become familiar with launching and connecting to on-demand Instances.
- Test connectivity for the VPC configuration we created in ex-002.

Expected Costs
--------------
The activities in this exercise may result in charges to your AWS account.

.. list-table::
   :widths: 20, 40, 50
   :header-rows: 0

   * - **Component**
     - **Applicable Costs**
     - **Notes**
   * - Security Groups
     - 
        + None
     -
   * - On-demand Instances
     - 
        + $0.0116 per hour per Instance (t2.micro)
     - 
        + During this exercise, we will use two (2) Instances. The AMI that will be used is **'Ubuntu Server 16.04 LTS'**, which combined with the **'t2.micro'** Instance Type, is **'Free tier eligible'**.
        + It is not expected that these Instances will need to be running for more than one hour.
   * - Elastic IPs
     - 
        + $0.00 per hour per EIP that is associated to a running Instance
        + $0.005 per hour per EIP that is NOT associated to a running Instance
     - 
        + During this exercise there will be short periods of time where an EIP is not associated with a running Instance, so you might incur a very small charge.
   * - Elastic IPs
     - 
        + $0.00 per EIP address remap for the first 100 remaps per month.
        + $0.10 per EIP address remap for additional remaps over 100 per month
     - 
        + During this exercise we will remap an EIP a couple of times.  

Limits
------
The following table shows the default limits for the components utilized in this exercise.

.. list-table::
   :widths: 25, 25
   :header-rows: 0

   * - **Component**
     - **Limit**
   * - Security Groups
     - 500 per VPC
   * - Security Groups per Elastic Network Interface
     - 5
   * - Rules per Security Group
     - 50
   * - On-demand Instances
     - 20 per region
   * - Elastic IP addresses
     - 5 per region

Preparation
-----------
Logon to your AWS accound and navigate to the AWS Management console

Create a Security Group
-----------------------
We'll create a Security Group will be applied to the Instances created later in this exercise.

1. Under the **Services** menu, select **EC2** under *Compute*
2. On the left-side menu, select **Security Groups** under NETWORK & SECURITY
3. Click 'Create Security Group'
4. In the 'Create Security Group' window, set the following values:
      * Security Group Name: Int2Public
      * Description: Security Group for Instances
      * VPC: Select the EX002_VPC
5. Under Security Group Rules, select the 'Inbound' tab and click 'Add Rule'  
6. In the Rule definition row, set the following values: 
      * Type: SSH (this sets protocol to TCP and port to 22)
      * Source: Anywhere (or My IP)
      * Description: Allow SSH inbound
7. Click **Create**
   
Launch an Instance
-------------------
1. On the left-side menu, select **Instances**
2. Click **Launch Instance**
3. At the 'Choose an Amazon Machine Image (AMI)' step, check the **Free tier only** check box on the left and select the 'Quick Start' tab.
4. Click **select** beside ``Ubuntu Server 16.04 LTS (HVM), SSD Volume Type``
5. At the 'Choose and Instance Type step, select **t2.micro** and click **Next: Configure Instance Details**
6. At the 'Configure Instance Details step, set the following values and click **Next: Add Storage**:
      * Network: EX002_VPC
      * Subnet: public
      * Everything else: default
7. At the 'Add Storage' step, make no changes and click **Next: Add Tags**
8. At the 'Add Tags' step, click **Add Tag**, enter the following, then click **Next: Configure Security Group**
      * Key: Name
      * Value: public
9. At the Configure Security Group step, choose **Select and existing Security Group** the select the Int2Public security group.  Its inbound rules, allowing SSH are displayed
10. Click **Review and Launch**, then **Launch**
11. At the 'Select and existing key pair or create a new key pair' window, select your keypair, check the 'I acknowledge..." box and click **Launch Instances**
12.  Click **View Instances** to watch the creation status.
      
Launch another Instance
-------------------
1. While stil in the Instances console
2. Click **Launch Instance**
3. At the 'Choose an Amazon Machine Image (AMI)' step, check the **Free tier only** check box on the left and select the 'Quick Start' tab.
4. Click **select** beside ``Ubuntu Server 16.04 LTS (HVM), SSD Volume Type``
5. At the 'Choose and Instance Type step, select **t2.micro** and click **Next: Configure Instance Details**
6. At the 'Configure Instance Details step, set the following values and click **Next: Add Storage**:
      * Network: EX002_VPC
      * Subnet: private
      * Everything else: default
7. At the 'Add Storage' step, make no changes and click **Next: Add Tags**
8. At the 'Add Tags' step, click **Add Tag**, enter the following, then click **Next: Configure Security Group**
      * Key: Name
      * Value: private
9. At the Configure Security Group step, choose **Select and existing Security Group** the select the Int2Public security group.  Its inbound rules, allowing SSH are displayed
10. Click **Review and Launch**, then **Launch**
11. At the 'Select and existing key pair or create a new key pair' window, select your keypair, check the 'I acknowledge..." box and click **Launch Instances**
12.  Click **View Instances** to watch the creation status.

Proceed when both instances have an Instance State of 'running'



Private IP address
------------------
Use the following awscli command to collect the IP address of the Instance on the **'private'** Subnet.

Note: you will type this address in a ssh session, so jot it down.

.. code-block::
    
    aws ec2 describe-instances \
        --instance-ids $EX003_INST_PRIV \
        --output text \
        --query Reservations[*].Instances[*].NetworkInterfaces[*].PrivateIpAddress

Output:

.. code-block::
    
    xxx.xxx.xxx.xxx

Using the **'--query Reservations[*].Instances[*].NetworkInterfaces[*].PrivateIpAddress'** parameter, dictates that only the value of **'PrivateIpAddress'** should be returned. Using the **'--output text'** parameter, dictates that result should be text and not the default json. 

Allocate an Elastic IP
----------------------
Now we need to allocate an Elastic IP (public IPv4 address). In the next step, we will associate it with the **public** Instance, so we can connect to it.

Note: This step and the next could have been handled as part of the **run-instances** command, by using the **'--associate-public-ip-address'** option.

Use the following awscli command to allocate an Elastic IP.

.. code-block::

    aws ec2 allocate-address --domain vpc

Output:

.. code-block::

    {
        "PublicIp": "xxx.xxx.xxx.xxx",
        "AllocationId": "eipalloc-xxxxxxxxxxxxxxxxx",
        "Domain": "vpc"
    }

Environment variable
~~~~~~~~~~~~~~~~~~~~
Set a couple of environment variables using the output above.

.. code-block::

    export EX003_EIP=<AllocationId>
    export EX003_PUB_IP=<PublicIp>

Associate the Elastic IP
------------------------
Use the following awscli command to associate the Elastic IP with the **public** Instance.

.. code-block::

    aws ec2 associate-address --allocation-id $EX003_EIP --instance-id $EX003_INST_PUB

Output:

.. code-block::

    {
        "AssociationId": "eipassoc-xxxxxxxxxxxxxxxxx"
    }

Confirm Association
-------------------
Run the following awscli command to verify that the Elastic IP has been associated with an instance.

.. code-block::

    aws ec2 describe-addresses

Output:

.. code-block::

    {
        "Addresses": [
            {
                "Domain": "vpc",
                "InstanceId": "i-xxxxxxxxxxxxxxxxxx",
                "NetworkInterfaceId": "eni-xxxxxxxx",
                "AssociationId": "eipassoc-xxxxxxxx",
                "NetworkInterfaceOwnerId": "xxxxxxxxxxxx",
                "PublicIp": "xxx.xxx.xxx.xxx",
                "AllocationId": "eipalloc-xxxxxxxx",
                "PrivateIpAddress": "xxx.xxx.xxx.xxx"
        }
    ]
}

Test inbound connectivity
-------------------------
Use the following commands to test 'inbound' connectivity to the **public** Instance.

**Expected results:** 'ping' should fail and 'ssh' should succeed.

.. code-block::

    ping $EX003_PUB_IP
    ssh -i acpkey1.pem -o ConnectTimeout=5 ubuntu@$EX003_PUB_IP

Note: If you are prompted with **"Are you sure you want to continue connecting (yes/no)?"**, that's a good thing! Enter 'y' and you'll be connected.

Test outbound connectivity
--------------------------
Use the following command to test 'outbound' connectivity from the **public** Instance.

**Expected results:** 'apt update' should succeed.

.. code-block::

    sudo apt update

Type 'exit' to close the ssh session to this instance

Re-associate the Elastic IP
---------------------------
Use the following awscli command to re-associate the Elastic IP with the **private** Instance.

.. code-block::

    aws ec2 associate-address --allocation-id $EX003_EIP --instance-id $EX003_INST_PRIV

Output:

.. code-block::

    {
        "AssociationId": "eipassoc-xxxxxxxxxxxxxxxxx"
    }

Test inbound connectivity
-------------------------
Use the following commands to test connectivity to the **private** Instance.

**Expected results:** Both 'ping' and 'ssh' should be fail.

.. code-block::

    ping $EX003_PUB_IP
    ssh -i acpkey1.pem -o ConnectTimeout=5 ubuntu@$EX003_PUB_IP

Re-associate the Elastic IP
---------------------------
Use the following awscli command to re-associate the Elastic IP with the **public** Instance.

.. code-block::

    aws ec2 associate-address --allocation-id $EX003_EIP --instance-id $EX003_INST_PUB

Output:

.. code-block::

    {
        "AssociationId": "eipassoc-xxxxxxxxxxxxxxxxx"
    }

Reconnect
-------
Use the following commands to:

    - Copy the '.pem' file to **public** Instance. We will need this to connect from the **public** Instance to the **private** Instance. 
    - Reconnect to the **public** Instance.

**If you are using a different Key Pair, then replace 'acpkey1.pem' with your '<your-pem-file>'**.


.. code-block::

    scp -i acpkey1.pem acpkey1.pem ubuntu@$EX003_PUB_IP:/home/ubuntu
    ssh -i acpkey1.pem -o ConnectTimeout=5 ubuntu@$EX003_PUB_IP

    Do NOT 'exit'

Test local connectivity
-----------------------
You should still be connected to the **public** Instance.

Use the following commands to test connectivity to the **private** Instance.

**Expected results:** 'ping' should fail and 'ssh' should succeed.

.. code-block::

    ping <ip-addr-private-instance>
    ssh -i acpkey1.pem -o ConnectTimeout=5 ubuntu@<ip-addr-private-instance>

You are now connected to the **private** Instance, through the **public** instance.

Test outbound connectivity
--------------------------
Use the following command to test oubound connectivity from the Instance in the private Subnet.

**Expected results** 'apt update' should fail.

.. code-block::

    sudo apt update

    Type 'cntrl-c' to kill 'apt'

Type 'exit' twice to close the ssh session for both Instances.

The private subnet has no inbound or outbound path to the Internet. In a later exercise, we will create a **NAT Gateway** to allow for outbound connectivity for private Subnet to the Internet.

Add a rule to the Security Group
--------------------------------
Use the following awscli command to create a new rule to the above security group. This rule enables the icmp protocol from anywhere.

Note: the command requires the 'port' parameter - AWS document has this to say:

    For ICMP: A single integer or a range (type-code ) representing the ICMP type number and the ICMP code number respectively. A value of -1 indicates all ICMP codes for all ICMP types. A value of -1 just for type indicates all ICMP codes for the specified ICMP type.

.. code-block::

    aws ec2 authorize-security-group-ingress --group-id $EX003_SG --protocol icmp --port -1 --cidr 0.0.0.0/0

Test connectivity
-----------------
Use the following commands to test connectivity to the **public** Instance.

**Expected results:** 'ping' and 'ssh' should now succeed.

.. code-block::

    ping $EX003_PUB_IP
    ssh -i acpkey1.pem -o ConnectTimeout=5 ubuntu@$EX003_PUB_IP

You are now connected to the **public** Instance.

Test local connectivity
-----------------------
You should still be connected to the **public** Instance.

Use the following command to test connectivity to the **private** Instance. 

**Expected results:** 'ping' should now succeed.

.. code-block::

    ping <ip-addr-private-instance>

Type 'exit' to disconnect to close the ssh session.

Terminate Instances
-------------------
Use the following awscli command to terminate both instances.

.. code-block::

    aws ec2  terminate-instances --instance-ids $EX003_INST_PUB $EX003_INST_PRIV

Examine the current state. Both should show a **'currentState'** of **'shutting-down'**.

This operation is idempotent. Rerun the command until you see a **'currentState'** of **'terminated'**.

Output:

.. code-block::

    {
        "TerminatingInstances": [
            {
                "CurrentState": {
                    "Code": 32,
                    "Name": "shutting-down"
                },
                "InstanceId": "i-xxxxxxxxxxxxxxxxx",
                "PreviousState": {
                    "Code": 16,
                    "Name": "running"
                }
            },
            {
                "CurrentState": {
                    "Code": 32,
                    "Name": "shutting-down"
                },
                "InstanceId": "i-xxxxxxxxxxxxxxxxx",
                "PreviousState": {
                    "Code": 16,
                    "Name": "running"
                }
            }
        ]
    }

Release the Elastic IP
----------------------
Use the following awscli command to release the Elastic IP.

Recall that leaving it allocated, but unassigned will incur a charge.

NOTE: The associated instance will have to complete its termination in order for the Elastic IP to not be **"In use"** and available for release

.. code-block::

    aws ec2 release-address --allocation-id $EX003_EIP

Delete the Security Group
-------------------------
Use the following awscli command to delete the Security Group.

.. code-block::

    aws ec2 delete-security-group --group-id $EX003_SG

Delete the VPC
--------------
Use the following awscli command to delete the VPC.

This will delete the VPC itself, plus the Subnets, Route Tables and Internet Gateway.

.. code-block::

    aws ec2 delete-vpc --vpc-id $EX003_VPC

Summary
-------
- We created a Security Group.
- We added rules to the Security Group.
- We create two Instances.
- We allocated a Elastic IP.
- We map/re-mapped that Elastic IP to Instances.
- We tested connectivity to/from both the 'public' and 'private' Instances.
- We terminated both Instance, released the Elastic IP, deleted the Security Group and the VPC (and associated components).

**Note: we did NOT delete the Key Pair, keep the '.pem' file safe** 

Next steps
----------
We will recreate the configuration built in ex-002 and ex-003, using CloudFormation, in 
`ex-004 <https://github.com/addr2data/aws-certification-prep/blob/master/exercises/ex-004_GettingStartedCloudFormation.rst>`_
