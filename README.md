# Systemd Journald Cloud Watch Log Forwarder

_Debian package to forward journald to cloud watch._

It's shockingly difficult to send your Journald logs to Cloud Watch.  Solutions
exist ([1](https://github.com/saymedia/journald-cloudwatch-logs),
[2](https://github.com/advantageous/systemd-cloud-watch)), but I had trouble
getting any of them to work correctly.

I finally found a script that worked
([juxt/rock](https://github.com/juxt/rock/tree/master/share/journald-cloud-watch-script)),
but I need to install this on a number of different servers/AMIs, so wanted to
have it as a standalone package.  _Voila_.

## Installing:

Attach the policy below to your instance, tag the instance with `Environment` and `Name` and then:

~~~ console
$ curl -sSLO https://github.com/superorbital/journald2cloudwatch/releases/download/v1.2.5/journald2cloudwatch_latest_all.deb
$ dpkg install ./journald2cloudwatch_latest_all.deb
~~~

You should now see logs in Cloud Watch.  If you don't, stop the service and run the command in a terminal to debug.

## Internals

This `.deb` package will install the
[journald2cloudwatch](/usr/bin/journald2cloudwatch) script as [a systemd
service](/lib/systemd/system/journald2cloudwatch.service).  The script requires
`jq` and `awscli` (both marked as dependencies).  It will send logs to Cloud
Watch using the group `journald` (configurable via the `$LOG_GROUP_NAME`
variable).  It uses the tags on the instance to name the stream.  Specifically,
it requires the instance to have the tags `Environment` and `Name`, and it then
names the stream `<Env>-<Name>`.  It will create the group on startup.

## AWS Instance Policy

This package requires the following instance policy snippet on your EC2 instance:

~~~ json
{
  "Sid": "DescribeTags",
  "Effect": "Allow",
  "Action": [ "ec2:DescribeTags" ],
  "Resource": ["*"]
},
{
  "Sid": "WriteLogs",
  "Effect": "Allow",
  "Action": [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents",
    "logs:DescribeLogStreams"
  ],
  "Resource": [
    "arn:aws:logs:*:*:log-group:*",
    "arn:aws:logs:*:*:log-group:*:log-stream:*"
  ]
}
~~~

An example terraform configuration would be:

~~~ terraform
resource "aws_iam_role" "example" {
  name_prefix = "example"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "example" {
  name = "example"
  role = "${aws_iam_role.example.name}"
}

resource "aws_iam_role_policy" "example" {
  name_prefix = "example"
  role        = "${aws_iam_role.example.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DescribeTags",
      "Effect": "Allow",
      "Action": [ "ec2:DescribeTags" ],
      "Resource": ["*"]
    },
    {
      "Sid": "WriteLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": [
        "arn:aws:logs:*:*:log-group:*",
        "arn:aws:logs:*:*:log-group:*:log-stream:*"
      ]
    }
  ]
}
EOF
}

resource "aws_instance" "example" {
  iam_instance_profile        = "${aws_iam_instance_profile.example.id}"
  # ...
  tags {
    Name        = "Example"
    Environment = "Staging"
  }
}
~~~

### Known Issues / Roadmap

* Runs the script as `root` in order to run `journalctl` and see all entries.  Would be good to figure out how to run as a regular user.
* Rewrite in Go to avoid potential security issues with shell escapes.
* Make instance tagging optional

## Credits

Again, due props: the bulk of the script was cribbed from [juxt/rock](https://github.com/juxt/rock/tree/master/share/journald-cloud-watch-script).

If you find this package useful, consider calling [SuperOrbital](https://superorbit.al) for your cloud native engineering and training needs!
