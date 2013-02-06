/* 
* vendorPrefix.js - Copyright(c) Addy Osmani 2011. 
* http://github.com/addyosmani 
* Tests for native support of a browser property in a specific context 
* If supported, a value will be returned. 
*/  
function getPrefix(prop, context) {  
    var vendorPrefixes = ['moz', 'webkit', 'khtml', 'o', 'ms'],  
        upper = prop.charAt(0).toUpperCase() + prop.slice(1),  
        pref, len = vendorPrefixes.length,  
        q = null;  
    while (len--) {  
        q = vendorPrefixes[len];  
        if (context.toString().indexOf('style')) {  
            q = q.charAt(0).toUpperCase() + q.slice(1);  
        }  
        if ((q + upper) in context) {  
            pref = (q);  
        }  
    }  
    if (prop in context) {  
        pref = prop;  
    }  
    if (pref) {  
        return '-' + pref.toLowerCase() + '-';  
    }  
    return '';  
}  