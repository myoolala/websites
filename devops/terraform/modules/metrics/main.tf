locals {
  pie_periods = [["hour", 60], ["day", 60 * 24], ["month", 60 * 24 * 30]]
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "Website-Stats"

  dashboard_body = jsonencode({
    widgets = concat([for i, v in var.domains : 
      {
        type   = "metric"
        x      = i * 8
        y      = 0
        width  = 8
        height = 6

        properties = {
          metrics = [
            [
              var.namespace,
              "RequestCount",
              "host",
              v
            ]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "Total GET requests for ${v}"
        }
      }
    ], [for i, v in local.pie_periods : 
      {
        "type": "metric",
        "x": i * 8,
        "y": 6,
        "width": 8,
        "height": 8,
        "properties": {
          "view": "pie",
          "region": "us-east-1",
          "title": "Host RequestCount — last ${v[0]}",
          "period": v[1],
          "stat": "Sum",
          "setPeriodToTimeRange": true,
          "metrics": [for i, v in var.domains : 
            [
              var.namespace,
              "RequestCount",
              "host",
              v,
              {
                "label": v
              }
            ]
          ]
        }
      }
    ])
  })
}