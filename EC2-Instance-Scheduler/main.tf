resource "aws_cloudformation_stack" "stack" {
  name = var.name
  parameters = {
    "SchedulingActive" = "Yes"
    "ScheduledServices" = "Both"
    "MemorySize" = 128
    "UseCloudWatchMetrics" = "Yes"
    "LogRetentionDays" = 30
    "Trace" = "Yes"
    "TagName" = "Schedule"
    "DefaultTimezone" = "America/Sao_Paulo"
    "Regions" = "us-east-1"
    "StartedTags" = "StartedBy=InstanceScheduler"
    "StoppedTags" = "StoppedBy=InstanceScheduler"
    "SchedulerFrequency" = "5"
    "ScheduleLambdaAccount" = "Yes"
    "SendAnonymousData" = "No"
    "CrossAccountRoles" = ""
  }

  template_body = file("aws-instance-scheduler.json")
  capabilities = ["CAPABILITY_NAMED_IAM"]

}