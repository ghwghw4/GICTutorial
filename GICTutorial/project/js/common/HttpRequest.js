
function httpRequest(opt) {
    opt = opt || {};
    opt.method = opt.method || 'POST';
    opt.url = opt.url || '';
    opt.async = opt.async || true;
    opt.data = opt.data || {};
    opt.headers = opt.headers || {};
    opt.success = opt.success || function () { };
    opt.error = opt.error || function () { };

    const xmlHttp = new XMLHttpRequest();
    if (!opt.headers['Content-Type']) {
        xmlHttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded;charset=utf-8');
    } else {
        Object.keys(opt.headers).forEach((key) => {
            xmlHttp.setRequestHeader(key, opt.headers[key]);
        });
    }

    // 请求参数设置
    const params = [];
    for (const key of Object.keys(opt.data)) {
        params.push(`${key}=${encodeURI(opt.data[key])}`);
    }

    var postData = params.join('&');
    if (opt.method.toUpperCase() === 'POST') {
        xmlHttp.open(opt.method, opt.url, opt.async);
        xmlHttp.send(postData);
    }
    else if (opt.method.toUpperCase() === 'GET') {
        let fullUrl = opt.url;
        if (postData.length > 0) {
            fullUrl += '?' + postData;
        }
        xmlHttp.open(opt.method, fullUrl, opt.async);
        xmlHttp.send(null);
    }
    xmlHttp.onreadystatechange = function () {

        if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
            opt.success(xmlHttp.responseText);
        } else {
            opt.error(xmlHttp.responseText);
        }
    };

    xmlHttp.onerror = function () {
        opt.error(xmlHttp.responseText);
    }
}

async function httpRequestAsync(opt) {

    opt = opt || {};
    opt.method = opt.method || 'POST';
    opt.url = opt.url || '';
    opt.async = opt.async || true;
    opt.data = opt.data || {};
    opt.headers = opt.headers || {};

    const xmlHttp = new XMLHttpRequest();
    if (!opt.headers['Content-Type']) {
        xmlHttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded;charset=utf-8');
    } else {
        Object.keys(opt.headers).forEach((key) => {
            xmlHttp.setRequestHeader(key, opt.headers[key]);
        });
    }

    // 请求参数设置
    const params = [];
    for (const key of Object.keys(opt.data)) {
        params.push(`${key}=${encodeURI(opt.data[key])}`);
    }

    var postData = params.join('&');
    if (opt.method.toUpperCase() === 'POST') {
        xmlHttp.open(opt.method, opt.url, opt.async);
        xmlHttp.send(postData);
    }
    else if (opt.method.toUpperCase() === 'GET') {
        let fullUrl = opt.url;
        if (postData.length > 0) {
            fullUrl += '?' + postData;
        }
        xmlHttp.open(opt.method, fullUrl, opt.async);
        xmlHttp.send(null);
    }

    return new Promise((resolve) => {
        xmlHttp.onreadystatechange = function () {
            if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
                resolve({response:xmlHttp.responseText});
            } else {
                resolve({error:new Error(xmlHttp.responseText)});
            }
        };

        xmlHttp.onerror = function (error) {
            resolve({error:error});
        };
    });
}

module.exports = { httpRequest, httpRequestAsync };