# GCS bucket rewrite

Host a static site on a GCS bucket through a load balancer.

We use the `Accept-Language` header with regex matching to determine the supported language of the user's client, then use URL rewriting to determine which version of our `index.html` to serve.  This shows the capabilities of [URL rewriting](https://cloud.google.com/load-balancing/docs/https/setting-up-url-rewrite) using the GCP global load balancer.    

Note this doesn't really support if users have multiple languages set up, and it just prioritizes English over French based on the rules set in the URL Map priorities (see [lb.tf](./lb.tf)). it's more to just demonstrate that you can control which objects are served based on a header value passed in by the client. 