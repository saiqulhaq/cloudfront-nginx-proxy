# CloudFront-nginx-proxy [![dev chat](https://discordapp.com/api/guilds/188630481301012481/widget.png?style=shield)](https://discord.gg/ppy)

This image is supposed to proxy to AWS CloudFront, not S3.
This is for easy replacement of CloudFront with CloudFlare running in Docker and Kubernetes.  
We can save the AWS cost first, then optimize the app later by deploying https://github.com/ppy/s3-nginx-proxy with full tests of our system  

# Features

- Cache duration based on HTTP status
- Auto-reload after every configuration update (in production too)
- Single-key cache purge support (using HTTP DELETE)
- Cloudflare cache purging support
- Observability (Prometheus-compatible)

# Usage

set the `upstream` key in the virtualhost json setting, for example:  

```json
  {
    "cacheKey": "random-key",
    "upstream": "xxxxx.cloudfront.net",
    "hostnames": [
      "proxy.domain.com"
    ],
    "defaultPath": "/blank.png",
    "defaultStatusCode": 200,
    "cache": {
      "200": "60m"
    }
  }

```

## Docker

Edit `./data/etc/proxy-config/virtualhosts.json` and `./data/etc/proxy-config/cache.json` to match your desired settings.
Start the NGINX and config generator containers with `docker-compose up -d`.

## Kubernetes (Helm)

Helm chart is available at https://github.com/saiqulhaq/helm-charts/tree/master/osu/cloudfront-nginx-proxy

## Purge configuration

Single files can be purged from cache using the HTTP `DELETE` method.

By default, this is enabled to everyone with no authentication.  
Authentication can be enabled by setting `purgeAuthorizationKey` in the cache config and using the HTTP `Authorization` header.

### Cloudflare purging

If Cloudflare is placed in front of s3-nginx-proxy, files can also be purged on Cloudflare's CDN using their API.

It can be enabled by setting the following variables in the cache config:
- `purgeCloudflareApiToken` must be a purging-enabled token.  
  Head to your [account's API Keys](https://dash.cloudflare.com/profile/api-tokens) and create a custom token with the `Zone > Cache Purge > Purge` permission enabled on the desired zone.
- `purgeCloudflareZoneId` is found on your domain's home page on your Cloudflare dashboard.

## Observability

A Prometheus-compatible metrics endpoint can be enabled in `metrics.json`.  
The following metrics are exposed:
- `nginx_http_requests_total`: Number of HTTP requests (counter)
- `nginx_http_request_duration_seconds`: HTTP request latency (histogram)
- `nginx_http_connections`: Number of HTTP connections (gauge)
- `nginx_upstream_cache_status`: Number of HTTP requests per upstream cache status (counter)

# Contributing

This project is very bare-bones for now; a sort of Minimum Viable Product.  
Planned features are the ability to purge cache (both full and specific key), and more configuration options.

Contributions can be made via pull requests to this repository. We hope to credit and reward larger contributions via a [bounty system](https://www.bountysource.com/teams/ppy). If you're unsure of what you can help with, check out the [list of open issues](https://github.com/ppy/s3-nginx-proxy/issues).

Note that while we already have certain standards in place, nothing is set in stone. If you have an issue with the way code is structured; with any libraries we are using; with any processes involved with contributing, *please* bring it up. I welcome all feedback so we can make contributing to this project as pain-free as possible.

# Licence

[MIT licence](https://opensource.org/licenses/MIT). Please see [the licence file](LICENCE) for more information. [tl;dr](https://tldrlegal.com/license/mit-license) you can do whatever you want as long as you include the original copyright and license notice in any copy of the software/source.
