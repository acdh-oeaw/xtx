xquery version "3.0";
module namespace trigger="http://exist-db.org/xquery/trigger";

import module namespace profile = "http://acdh.oeaw.ac.at/apps/xtx/profile" at "profile.xqm";

declare function trigger:after-update-document($uri as xs:anyURI) {
    let $log := util:log("INFO", "triggered "||$uri)
    let $id := doc($uri)/profile/@id
    return 
        if (ends-with($uri,'profile.xml') and $id != '')
        then profile:prepare($id)
        else ()
};

declare function trigger:after-create-document($uri as xs:anyURI) {
    let $log := util:log("INFO", "triggered "||$uri)
    let $id := doc($uri)/profile/@id
    return 
        if (ends-with($uri,'profile.xml') and $id != '')
        then profile:prepare($id)
        else ()
};