## 代理服务器网址
1. NSB: http://cnproxy.int.nokia-sbell.com/proxy.pac
2. Global: http://proxyconf.glb.nokia.com/proxy.pac

## Nokia代理服务器
#### 国内代理:
1. nsb-proxy.lb.int.nokia-sbell.com:8080
2. 135.245.192.7:8000
3. 100.101.1.2:8080

#### 国外代理
1. fihelprx-defraprx.glb.nsn-net.net:8080
2. defraprx-fihelprx.glb.nsn-net.net:8080
3. 10.144.1.10:8080

# 自定义PAC代理
```javascript
// Customized funcitons added here
var isHome = null;
function isHomeNetwork() {
  if (isHome !== null) {
      return isHome;
  }
  isHome = isInNet(myIpAddress(), "10.0.0.0", "255.255.255.0");
  return isHome;
}

function isHomeIp(host) {
  if (!isHomeNetwork()) {
      return false;
  }

  return shExpMatch(host, "10.0.0.*") ||
         shExpMatch(host, "192.168.1.*") ||
         isInNet(host, "10.0.0.0", "255.255.255.0") ||
         isInNet(host, "192.168.1.0", "255.255.255.0");
}

function isBlockedByCNFirewall(host) {
  return (
    dnsDomainIs(host, ".google.com") ||
    dnsDomainIs(host, ".googleapis.com") ||
    dnsDomainIs(host, ".gstatic.com") ||
    dnsDomainIs(host, ".youtube.com") ||
    dnsDomainIs(host, ".googlevideo.com") ||
    dnsDomainIs(host, ".github.com") ||
    dnsDomainIs(host, ".githubusercontent.com") ||
    dnsDomainIs(host, ".openai.com") ||
    dnsDomainIs(host, ".chatgpt.com") ||
    dnsDomainIs(host, ".twitter.com") ||
    dnsDomainIs(host, ".x.com") ||
    dnsDomainIs(host, ".facebook.com") ||
    dnsDomainIs(host, ".fbcdn.net") ||
    dnsDomainIs(host, ".instagram.com") ||
    dnsDomainIs(host, ".whatsapp.com") ||
    dnsDomainIs(host, ".telegram.org") ||
    dnsDomainIs(host, ".cloudflare.com")
  );
}

function isChinaOptimizedIP(ip) {
  return (
    /* China Telecom */
    isInNet(ip, "14.0.0.0", "255.224.0.0") ||
    isInNet(ip, "27.0.0.0", "255.128.0.0") ||

    /* China Unicom */
    isInNet(ip, "58.0.0.0", "255.128.0.0") ||
    isInNet(ip, "59.0.0.0", "255.192.0.0") ||

    /* China Mobile */
    isInNet(ip, "60.0.0.0", "255.224.0.0") ||
    isInNet(ip, "112.0.0.0", "255.128.0.0") ||

    /* Alibaba Cloud (whitelist only) */
    isInNet(ip, "47.0.0.0", "255.0.0.0") ||

    /* Tencent Cloud (whitelist only) */
    isInNet(ip, "49.4.0.0", "255.252.0.0")
  );
}

function isMicrosoftDomain(host) {
  return (
    dnsDomainIs(host, ".microsoft.com") ||
    dnsDomainIs(host, ".office.com") ||
    dnsDomainIs(host, ".office365.com") ||
    dnsDomainIs(host, ".windows.net") ||
    dnsDomainIs(host, ".outlook.com") ||
    dnsDomainIs(host, ".live.com")
  );
}

function isAppleDomain(host) {
  return (
    dnsDomainIs(host, ".apple.com") ||
    dnsDomainIs(host, ".icloud.com") ||
    dnsDomainIs(host, ".mzstatic.com")
  );
}

function isAdobeDomain(host) {
  return dnsDomainIs(host, ".adobe.com");
}

function isPublicInfraDomain(host) {
  return (
    dnsDomainIs(host, ".speedtest.net") ||
    dnsDomainIs(host, ".ooklaserver.net") ||
    dnsDomainIs(host, ".akadns.net")
  );
}

function isChinaCloudDomain(host) {
  return (
    dnsDomainIs(host, ".aliyuncs.com") ||
    dnsDomainIs(host, ".aliyun.com") ||
    dnsDomainIs(host, ".tencentcloud.com") ||
    dnsDomainIs(host, ".myqcloud.com") ||
    dnsDomainIs(host, ".huaweicloud.com")
  );
}

function isFastInChinaDomain(host) {
  return (
//  isMicrosoftDomain(host) ||
  isAppleDomain(host) ||
  isAdobeDomain(host) ||
  isPublicInfraDomain(host) ||
  isChinaCloudDomain(host)
  );
}

/*
 * Decision priority:
 * 1. CN firewall blocked domains -> Foreign proxy
 * 2. China-fast domains or China-optimized IPs
 *    - Home: DIRECT
 *    - Office: CN proxy
 * 3. Final fallback chain
 */
function selectCustomizedProxy(host, resolved_host, default_proxy) {
  var HOME_PROXY = "DIRECT";
  var CN_PROXY = "PROXY nsb-proxy.lb.int.nokia-sbell.com:8080";
  var GB_PROXY = "PROXY fihelprx-defraprx.glb.nsn-net.net:8080; PROXY defraprx-fihelprx.glb.nsn-net.net:8080";
  var CN_PROXY_CHAIN = default_proxy ? default_proxy + ";" + CN_PROXY : CN_PROXY;
  
  if (isHomeIp(host)) {
    return "DIRECT";
  }
  
  if (isBlockedByCNFirewall(host)) {
      return GB_PROXY;
  }
  
  if (isFastInChinaDomain(host) ||
      (resolved_host && isChinaOptimizedIP(resolved_host))) {
      return isHomeNetwork() ? HOME_PROXY : CN_PROXY;
  }
  
  return GB_PROXY + ";" + CN_PROXY_CHAIN + ";" + "DIRECT";
}

// Customized funcitons added above this line

/*
** automatic proxy configuration V2.1 for 10.141.33.53 from cnproxy.int.nokia-sbell.com (10.158.127.244)
*/
function FindProxyForURL(url, host) {
 var resolved_host = null;
 var proxy=null;
  
  // return proxy; 
  return selectCustomizedProxy(host, resolved_host, proxy);
}
```
