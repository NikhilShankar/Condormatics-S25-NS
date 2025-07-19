resource "aws_cloudwatch_dashboard" "demo-dashboard" {
  dashboard_name = "demo-dashboard-${aws_instance.nginx1.id}"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              "${aws_instance.nginx1.id}"
            ]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "${aws_instance.nginx1.id} - CPU Utilization"
        }
      },
      {
        type   = "text"
        x      = 0
        y      = 7
        width  = 3
        height = 3

        properties = {
          markdown = "My Demo Dashboard"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/EC2",
              "NetworkIn",
              "InstanceId",
              "${aws_instance.nginx1.id}"
            ]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "${aws_instance.nginx1.id} - NetworkIn"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/EC2",
              "NetworkIn",
              "InstanceId",
              "${aws_instance.nginx2.id}"
            ]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "${aws_instance.nginx2.id} - NetworkIn"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "ec2-cpu-alarm" {
  alarm_name                = "terraform-ec2-cpu-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization reaches 80%"
  insufficient_data_actions = []
}
