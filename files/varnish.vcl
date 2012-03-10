# VCL file optimized for Plone with a webserver in front.  See vcl(7) for details
include "/etc/varnish/backends.vcl";
include "/etc/varnish/directors.vcl";
include "/etc/varnish/sites.vcl";

# Define a sub to handle requests where we ignore cache-control headers.  Now
# we don't have to put the check for a 200 status code in every content type:
sub override {
    if (beresp.status == 200) {
    return(deliver);
    }
    return(pass);
}

acl purge {
    "localhost";
    "127.0.0.1";
    "192.168.7.4";
    "192.168.7.7";
}

sub vcl_recv {

    if (req.request == "PURGE") {
            if (!client.ip ~ purge) {
                    error 405 "Not allowed.";
            }
            purge_url(req.url);
        error 200 "Purged";
    }
    if (req.request != "GET" && req.request != "HEAD") {
        /* We only deal with GET and HEAD by default */
        return(pass);
    }
    return(lookup);
}

sub vcl_hit {
    if (req.request == "PURGE") {
    set obj.ttl = 0s;
    error 200 "Purged";
    }
    if (!obj.cacheable) {
        set obj.http.X-Varnish-Action = "return(pass) (not cacheable - hit)";
        return(pass);
    }
    if (obj.http.Cache-Control ~ "(stale-while-revalidate|no-transform)") {
        # This is a special cache. Don't serve to authenticated.
        if (req.http.Cookie ~ "__ac=" || req.http.Authorization) {
            set obj.http.X-Varnish-Action = "return(pass) (special not cacheable - hit)";
                    return(pass);
                }
        }

    set obj.http.X-Varnish-Action = "HIT (return(deliver) - from cache)";
    return(deliver);
}

sub vcl_miss {
    if (req.request == "PURGE") {
            error 404 "Not in cache.";
    }
    return(fetch);
}

sub vcl_fetch {
    if (req.http.Cache-Control ~ "(stale-while-revalidate|no-transform)") {
            # Leveraging a non-varnish token to set a minimum ttl without contaminating s-maxage
            # Wouldn't need this if varnish supported Surrogate-Control
            if (beresp.ttl < 3600s) {
                    set req.http.X-Varnish-Special = "SPECIAL (local proxy for 1 hour)";
                    unset req.http.expires;
                    set beresp.ttl = 3600s;
                    # Add reset marker
                    set req.http.reset-age = "1";
            }
    }

    if (req.url ~ "\.(jpg|jpeg|gif|png|tiff|tif|svg|swf|ico|css|js|kss|vsd|doc|ppt|pps|xls|pdf|mp3|mp4|m4a|ogg|mov|avi|wmv|sxw|zip|gz|bz2|tgz|tar|rar|odc|odb|odf|odg|odi|odp|ods|odt|sxc|sxd|sxi|sxw|dmg|torrent|deb|msi|iso|rpm)$") {
        set beresp.ttl = 86400s;
        call override;
    }
    if (req.http.Content-Type ~ "image.*$") {
        set beresp.ttl = 86400s;
        call override;
    }
    if (req.http.Set-Cookie) {
            set req.http.X-Varnish-Action = "FETCH (return(pass) - response sets cookie)";
            return(pass);
    }
    if (req.http.Authorization && !req.http.Cache-Control ~ "public") {
            set req.http.X-Varnish-Action = "FETCH (return(pass) - authorized and no public cache control)";
            return(pass);
    }
    if (req.http.cookie ~ "__ac.*$") {
        return(pass);
    }
    if (!beresp.cacheable) {
    set req.http.X-Varnish-Action = "FETCH (return(pass) - not cacheable)";
        return(pass);
    }
    return(deliver);
}
