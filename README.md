# HTTPBench

This is a Ruby Kata on implementing HTTPBench tool.

## Original specification

1. The tool reads a list of URLs from a file, e.g.:

        http://www.google.com
        www.facebook.com:443
        https://twitter.com
        www.xkcd.com/443?foo=bar

2. For each URL, it executes GET request and measures the latency,
writing all results into a JSON file, e.g.:

        [{"url": "http://www.google.com", "latency_ms": 3210},
         {"url": "https://www.facebook.com:443", "latency_ms": 1232},
         {"url": "https://twitter.com", "latency_ms": 315},
         {"url": "http://www.xkcd.com/443?foo=bar", "latency_ms": 132}]

## Modifications

Based on my own idea of a useful benchmarking tool, the following modifications
have been made to the original spec.

1. The tool must be able to use either files, or stdin/stdout for data
input/output.

2. The report must provide separate values for the connect and read time, as
well as http status code received with the response.

## Requirements

The tool itself has no runtime dependencies, except for Ruby - it runs on a
standard installation of Ruby 2.2.

To run the test, `minitest` gem is required (bundled with Ruby as part of its
stdlib, or available via rubygems).

## Quick start

Assuming that URL file is at `~/Temp/urls` path, and you want to see the report
written to `report` file, execute this command:

        ./httpbench -i ~/Temp/urls

Omit `-i` and `-o` to use stdin/stdout instead.

See `httpbench -h` for a full list of options.

## Running with docker

If you don't have Ruby installed, and don't want to have on installed - the tool
is available as a standalone docker image. To run the image:

        $ docker pull morhekil/httpbenchrb
        $ alias hb='docker run -a stdout -a stdin -i --rm=true morhekil/httpbenchrb ./httpbench'
        $ cat ~/Temp/urls | hb

Note that docker container normally do not have access to your local filesystem,
so you can either use stdin/stdout to pass data in and out, or mount a directory
into the container to use the file-based operation mode.

## Example of a final report

        [
          {
            "url": "www.xkcd.com/443?foo=bar",
            "connect_ms": 1270,
            "read_ms": 442,
            "status": "301"
          },
          {
            "url": "https://twitter.com",
            "connect_ms": 1523,
            "read_ms": 351,
            "status": "200"
          },
          {
            "url": "http://www.google.com",
            "connect_ms": 163,
            "read_ms": 10,
            "status": "302"
          },
          {
            "url": "www.facebook.com:443",
            "connect_ms": 1570,
            "read_ms": 600,
            "status": "200"
          },
          {
            "url": "1.0.0.2",
            "error": "#<Net::OpenTimeout: execution expired>"
          }
        ]

## Executing tests

        rake tests

Through docker:

        docker run --rm=true morhekil/httpbenchrb rake test
