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

sub vcl_error {
    set obj.http.Content-Type = "text/html; charset=utf-8";

    synthetic {"
<html><head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title qtlid="187136">503 Service Maintenance</title>
    <meta http-equiv="revisit-after" name="Revisit-after" content="2 days">
    <meta http-equiv="robots" name="Robots" content="all">
    <meta name="robots" content="INDEX|FOLLOW">
    <meta http-equiv="cache-control" content="no-cache">
    <meta http-equiv="pragma" content="no-cache">
    <meta content="-1" http-equiv="Expires">
    <style type="text/css">
        body {
        color:#393733;
        background-color : #FFFFFF;
        }
        
        #wrapper {
        width:900px;
        margin:auto;
        padding:0;
        border: 1px #DFDFDF solid;
        }
        .header{background-color: #EFEFEF;
        }

        .not-found {
        -moz-background-clip:border;
        -moz-background-inline-policy:continuous;
        -moz-background-origin:padding;
        background:#ffffff url(http://rp1.irisnet.be/img/maintenance.jpg) no-repeat scroll 0 0;
        padding:30px 30px 100px 250px;
        text-align: Left;
        height: 150px;
        }
        
        .content{}
        
        .footer{ margin-top: 20px;
        text-align: center;
        background-color: #EFEFEF;
        padding:5px 5px 5px 5px;
        }
        
        body, td, th, textarea, input, select, h2, h3, h4, h5, h6 {
        font-family:arial,helvetica,sans-serif;
        font-size:83%;
        font-size-adjust:none;
        font-style:normal;
        font-variant:normal;
        font-weight:normal;
        line-height:1.4;
        }

        h1 {
        clear:left;
        color:#4E463F;
        font-size:300%;
        font-weight:normal;
        letter-spacing:-1px;
        margin:0 0 0.2em;
        }
        
        
        h2 {
        clear:left;
        color:#4E463F;
        font-size:150%;
        font-weight:normal;
        letter-spacing:-1px;
        margin:0 0 0.2em;
        
        }
        li {
        display:list-item;
        }
        ul{
        list-style-type:disc;
        }
        .mytext{text-align: center;
        vertical-align: top;
        width: 300px;}
    </style>
<style type="text/css"></style></head>
<body>
    <div id="wrapper">
        <div class="header">
            <table>
            <tbody><tr>
                <td class="mytext">
                BRIC
                </td>
                <td class="mytext">
                CIRB
                </td>
                <td class="mytext">
                CIBG
                </td>
            </tr>
            </tbody></table>
        </div>
        <div class="not-found"><h1>Sorry - D&eacute;sol&eacute;</h1>

        
        </div>
        <div class="content">
        <table>
            <tbody><tr>
                <td class="mytext">
                    <h2>This site is under maintenance.</h2>
                    <p>The site which you are trying to access is unavailable as it is being updated. We are doing our utmost to restore it as quickly as possible. </p>
                    <p>If the problem persists or for more information, please do not hesitate to contact Iris Line: 02 801 00 00 or irisline@cirb.irisnet.be.</p>
                    <p>We apologise for any inconvenience caused.</p>
                    <p>Brussels Regional Informatics Center</p>
                </td>
                <td class="mytext">
                    <h2>Ce site est sous maintenance</h2>
                    <p>Le site auquel vous tentez d'acc&eacute;der est indisponible en raison d'une mise à jour. Nous mettons tout en œuvre pour le r&eacute;tablir dans les meilleurs d&eacute;lais.</p>
                    <p>Si le problème persiste ou pour obtenir plus d'informations, n’h&eacute;sitez pas à contacter Iris Line : 02 801 00 00 ou irisline@cirb.irisnet.be.</p>
                    <p>Nous vous pr&eacute;sentons nos excuses pour cet inconv&eacute;nient.</p>
                    <p>Le Centre d'Informatique pour la R&eacute;gion Bruxelloise</p>
                </td>
                <td class="mytext">
                    <h2>Deze website is in onderhoud.</h2>
                    <p>De website die u wilt openen, is wegens updatingwerkzaamheden onbeschikbaar. Wij stellen alles in het werk om dit zo snel mogelijk te verhelpen.</p>
                    <p>Indien het probleem aanhoudt of voor meer informatie, neem gerust contact op met Iris Line: 02 801 00 00 of irisline@cibg.irisnet.be.</p>
                    <p>Wij verontschuldigen ons voor dit ongemak.</p>
                    <p>Het Centrum voor Informatica voor het Brusselse Gewest</p>
                </td>
                </tr>
        </tbody></table>
        </div>
        <div class="Footer">
            Varnish error: "} obj.status " " obj.response {"
            Host: <script type="text/javascript" language="javascript">document.write( window.location.href );</script>
        </div>
    </div>

</body></html>

    "};
    return(deliver);
}
