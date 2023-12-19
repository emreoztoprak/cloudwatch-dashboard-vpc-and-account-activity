resource "aws_cloudwatch_dashboard" "observability_dashboard" {
  dashboard_name = "Observability_Dashboard"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "log",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.cloudtrail_log_group}' | fields @timestamp, eventSource, eventName | filter eventSource = 'iam.amazonaws.com' and (eventName = 'CreatePolicy' or eventName = 'DeletePolicy' or eventName = 'UpdatePolicy' or eventName='AttachUserPolicy' or eventName='DetachUserPolicy' or eventName='PutUserPolicy' or eventName='DeleteUserPolicy' or eventName='AttachRolePolicy' or eventName='DetachRolePolicy' or eventName='PutRolePolicy' or eventName='DeleteRolePolicy') | stats count() by eventName",
        "view": "table",
        "region": "${var.region}",
        "title": "IAM Policy Changes"
      }
    },
    {
      "type": "log",
      "x": 12,
      "y": 12,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.cloudtrail_log_group}' | fields @timestamp, eventSource, eventName | filter eventSource = 'iam.amazonaws.com' and (eventName = 'AddUserToGroup' or eventName = 'ChangePassword' or eventName = 'CreateGroup' or eventName='CreateInstanceProfile' or eventName='CreateLoginProfile' or eventName='CreateRole' or eventName='CreateUser' or eventName='DeactivateMFADevice' or eventName='DeleteGroup' or eventName='DeleteGroupPolicy' or eventName='DeleteInstanceProfile' or eventName='DeleteLoginProfile' or eventName='DeleteRole' or eventName='DeleteUser' or eventName='DeleteVirtualMFADevice' or eventName='RemoveRoleFromInstanceProfile' or eventName='RemoveUserFromGroup' or eventName='UpdateLoginProfile') | stats count() by eventName",
        "view": "table",
        "region": "${var.region}",
        "title": "IAM User-Group-Role Changes"
      }
    },
    {
      "type": "log",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.cloudtrail_log_group}' | fields @timestamp, eventSource, eventName, errorMessage | filter eventSource = 'signin.amazonaws.com' and eventName='ConsoleLogin' and errorMessage='Failed authentication' | stats count() as Failed_Console_Login by bin(5m)",
        "view": "timeSeries",
        "region": "${var.region}",
        "title": "Failed Console Login"
      }
    },
    {
      "type": "log",
      "x": 12,
      "y": 12,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.cloudtrail_log_group}' | fields @timestamp, eventSource, eventName, userIdentity.userName | filter errorCode='Client.UnauthorizedOperation' or errorCode='AccessDenied' | stats count() as Access_Denied by bin(5m)",
        "view": "timeSeries",
        "region": "${var.region}",
        "title": "Denied Accesses"
      }
    },
    {
      "type": "log",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.cloudtrail_log_group}' | fields @timestamp, eventSource, eventName, userIdentity.userName | filter errorCode='Client.UnauthorizedOperation' or errorCode='AccessDenied' | stats count() as Total_Denied_Access by eventSource | sort Total_Denied_Access desc | limit 10",
        "view": "pie",
        "region": "${var.region}",
        "title": "Denied Accesses by Service"
      }
    },
    {
      "type": "log",
      "x": 12,
      "y": 12,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.cloudtrail_log_group}' | fields @timestamp, eventSource, eventName, userIdentity.userName | filter errorCode='Client.UnauthorizedOperation' or errorCode='AccessDenied' | stats count() as Total_Denied_Access by userIdentity.userName | sort Total_Denied_Access desc | limit 10",
        "view": "pie",
        "region": "${var.region}",
        "title": "Denied Accesses by User"
      }
    },
    {
      "type": "log",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.cloudtrail_log_group}' | fields @timestamp, @message, userIdentity.type | filter userIdentity.type='Root' | stats count() as RootActivity by bin(5m)",
        "view": "timeSeries",
        "region": "${var.region}",
        "title": "Root Account Activity"
      }
    },
    {
      "type": "log",
      "x": 12,
      "y": 12,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.cloudtrail_log_group}' | fields eventTime, userIdentity.arn as UserARN, requestParameters.target as InstanceID, responseElements.sessionId as SessionID | filter eventSource='ssm.amazonaws.com' and eventName='StartSession'",
        "view": "table",
        "region": "${var.region}",
        "title": "SSM Sessions"
      }
    },
    {
      "type": "log",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.cloudtrail_log_group}' | fields @timestamp, eventName, requestParameters.groupId as SecurityGroup_ID, requestParameters.groupName as SecurityGroup_Name, requestParameters.ipPermissions.items.0.fromPort as SourcePort, requestParameters.ipPermissions.items.0.toPort as TargetPort, requestParameters.ipPermissions.items.0.ipRanges.items.0.cidrIp as Allowed_IP | filter eventName = 'AuthorizeSecurityGroupIngress' or eventName = 'AuthorizeSecurityGroupEgress' or eventName = 'RevokeSecurityGroupIngress' or eventName = 'RevokeSecurityGroupEgress' or eventName = 'CreateSecurityGroup' or eventName = 'DeleteSecurityGroup' | sort @timestamp desc",
        "view": "table",
        "region": "${var.region}",
        "title": "Security Group Changes"
      }
    },
    {
      "type": "log",
      "x": 12,
      "y": 12,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.cloudtrail_log_group}' | fields @timestamp, eventName, requestParameters.networkAclId as NACL_ID, requestParameters.portRange.from as Source_Port, requestParameters.portRange.to as Target_Port, requestParameters.cidrBlock as Allowed_IP, requestParameters.ruleNumber as Rule_Number, requestParameters.ruleAction as Rule_Action, sourceIPAddress as Source_IP, awsRegion as AWS_Region, userIdentity.arn as User_Arn | filter eventName = 'CreateNetworkAcl' OR eventName = 'CreateNetworkAclEntry' OR eventName = 'DeleteNetworkAcl' OR eventName = 'DeleteNetworkAclEntry' OR eventName = 'ReplaceNetworkAclEntry' OR eventName = 'ReplaceNetworkAclAssociation' | sort @timestamp desc",
        "view": "table",
        "region": "${var.region}",
        "title": "NACL Changes"
      }
    },
    {
      "type": "log",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.cloudtrail_log_group}' | fields @timestamp, eventName, responseElements.accessKey.userName as UserName, userIdentity.arn as User, sourceIPAddress as IP_Address | filter eventSource = 'iam.amazonaws.com' and (eventName = 'CreateAccessKey' or eventName = 'DeleteAccessKey' or eventName = 'UpdateAccessKey')",
        "view": "table",
        "region": "${var.region}",
        "title": "Access Key Changes"
      }
    },
    {
      "type": "log",
      "x": 12,
      "y": 12,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.cloudtrail_log_group}' | fields @timestamp, eventSource, eventName, requestParameters.policyName, userIdentity.userName, userIdentity.arn, requestParameters.newPolicyDocument, requestParameters.oldPolicyDocument | filter eventSource = 's3.amazonaws.com' and (eventName = 'DeleteBucketPolicy' or eventName = 'PutBucketAcl' or eventName='PutBucketPolicy') | stats count() by eventName",
        "view": "table",
        "region": "${var.region}",
        "title": "S3 Policy Changes"
      }
    },
    {
      "type": "log",
      "x": 0,
      "y": 0,
      "width": 6,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.vpc_log_group}' | fields srcAddr as Source_IP | stats count(*) as Count by Source_IP | sort Count desc | limit 10",
        "view": "pie",
        "region": "${var.region}",
        "title": "Top 10 Source IP Address"
      }
    },
    {
      "type": "log",
      "x": 6,
      "y": 6,
      "width": 6,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.vpc_log_group}' | fields dstAddr as Destination_IP | stats count(*) as Count by Destination_IP | sort Count desc | limit 10",
        "view": "pie",
        "region": "${var.region}",
        "title": "Top 10 Destination IP Address"
      }
    },
    {
      "type": "log",
      "x": 12,
      "y": 12,
      "width": 6,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.vpc_log_group}' | fields srcAddr as Source_IP | filter action = 'REJECT' | stats count(*) as Count by Source_IP | sort Count desc | limit 10",
        "view": "pie",
        "region": "${var.region}",
        "title": "Top 10 Source Rejected IP Address"
      }
    },
    {
      "type": "log",
      "x": 18,
      "y": 18,
      "width": 6,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.vpc_log_group}' | fields dstAddr as Destination_IP | filter action = 'REJECT' | stats count(*) as Count by Destination_IP | sort Count desc | limit 10",
        "view": "pie",
        "region": "${var.region}",
        "title": "Top 10 Destination Rejected IP Address"
      }
    },
    {
      "type": "log",
      "x": 0,
      "y": 12,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.vpc_log_group}' | fields bytes, action | filter action='REJECT' | stats sum(bytes / 1048576) as totalBytes_MB by bin(5m) | sort @timestamp desc",
        "view": "timeSeries",
        "stacked": true,
        "region": "${var.region}",
        "title": "Rejected Packets"
      }
    },
    {
      "type": "log",
      "x": 20,
      "y": 20,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.vpc_log_group}' | fields bytes, action | filter action='ACCEPT' | stats sum(bytes / 1048576) as totalBytes_MB by bin(5m) | sort @timestamp desc",
        "view": "timeSeries",
        "stacked": true,
        "region": "${var.region}",
        "title": "Accepted Packets"
      }
    },
    {
      "type": "log",
      "x": 0,
      "y": 21,
      "width": 6,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.vpc_log_group}' | fields bytes, action | stats sum(bytes / 1048576) as Traffic_MB by action | sort Traffic_MB desc",
        "view": "pie",
        "region": "${var.region}",
        "title": "VPC Packets"
      }
    },
    {
      "type": "log",
      "x": 0,
      "y": 20,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.vpc_log_group}' | stats sum(bytes / 1048576) as bytesTransferred_MB by srcAddr as Source_IP, dstAddr as Destination_IP | sort bytesTransferred_MB desc | limit 10",
        "view": "table",
        "region": "${var.region}",
        "title": "Top 10 data transfers by source and destination IP addresses"
      }
    },
    {
      "type": "log",
      "x": 6,
      "y": 21,
      "width": 6,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.vpc_log_group}' | stats sum(bytes / 1048576) as Traffic_MB by azId | sort Traffic_MB desc",
        "view": "pie",
        "region": "${var.region}",
        "title": "Traffic Per AZ"
      }
    },
    {
      "type": "log",
      "x": 21,
      "y": 20,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.vpc_log_group}' | stats avg(bytes), min(bytes), max(bytes) by bin(5m) as t | sort t",
        "view": "timeSeries",
        "stacked": false,
        "region": "${var.region}",
        "title": "Min_Max_Avg Bytes"
      }
    },
    {
      "type": "log",
      "x": 0,
      "y": 22,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.vpc_log_group}' | stats avg( end - start)/1000 as latency group by srcAddr as Source_IP, dstAddr as Destination_IP| sort by latency desc| limit 10",
        "view": "table",
        "region": "${var.region}",
        "title": "Network Latency"
      }
    },
    {
      "type": "log",
      "x": 15,
      "y": 21,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.vpc_log_group}' | filter dstPort=80 and not(isempty(instanceId))| stats sum(bytes) as BytesReceived by instanceId | sort by BytesReceived desc",
        "view": "pie",
        "region": "${var.region}",
        "title": "Incoming HTTP Traffic Per Instance"
      }
    },
    {
      "type": "log",
      "x": 12,
      "y": 22,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.vpc_log_group}' | stats sum(bytes / 1048576) as Bytes_MB by flowDirection | sort by Bytes_MB desc",
        "view": "bar",
        "region": "${var.region}",
        "title": "Traffic by Direction"
      }
    },
    {
      "type": "log",
      "x": 0,
      "y": 23,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.vpc_log_group}' | filter flowDirection='ingress' |stats sum(bytes) as bytesTransferred by bin(5m)",
        "view": "timeSeries",
        "stacked": true,
        "region": "${var.region}",
        "title": "Ingress Traffic"
      }
    },
    {
      "type": "log",
      "x": 12,
      "y": 23,
      "width": 12,
      "height": 6,
      "properties": {
        "query": "SOURCE '${var.vpc_log_group}' | filter flowDirection='egress' |stats sum(bytes) as bytesTransferred by bin(5m)",
        "view": "timeSeries",
        "stacked": true,
        "region": "${var.region}",
        "title": "Egress Traffic"
      }
    }
  ]
}
EOF
}