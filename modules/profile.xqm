xquery version "3.0";

module namespace profile = "http://acdh.oeaw.ac.at/apps/xtx/profile";
declare namespace rest="http://exquery.org/ns/restxq";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";

import module namespace config = "http://acdh.oeaw.ac.at/apps/xtx/config" at "config.xqm";

declare function profile:home($id as xs:string) {
    let $profile := profile:read($id)
    return
    if (exists($profile))
    then util:collection-name($profile)
    else error(xs:QName('profile:unknownProfile'), 'Unknown profile', $id)
};

declare function profile:create($profile as document-node()) as xs:string {
    let $id := util:uuid()
    return
        if ($id)
        then 
            let $col := xmldb:create-collection($config:profiles, $id), 
                $store := xmldb:store($config:profiles||"/"||$id, "profile.xml", $profile),
                $set-id := update value doc($config:profiles||"/"||$id||"/profile.xml")/profile/@id with $id,
                $set-created := update value doc($config:profiles||"/"||$id||"/profile.xml")/profile/@created with current-dateTime()
            return $id
        else () 
};

declare function profile:read($id as xs:string) as element(profile) {
    collection($config:profiles)//profile[@id = $id]
};

declare function profile:update($id as xs:string, $data as document-node()) {
    let $profile-home := profile:home($id)
    return xmldb:store($profile-home, "profile.xml", $data)
};

declare function profile:delete($id as xs:string) {
    let $profile-home := profile:home($id)
    return xmldb:remove($profile-home) 
};

declare function profile:prepare($id as xs:string) {
    (:get the profile:)
    let $profile := profile:read($id),
        $profile-home := profile:home($id)
    return 
        if (not(exists($profile)))
        then error(xs:QName('profile:unknownProfile'), 'Unknown profile', $id)
        else if ($profile-home = "")
        then error(xs:QName('profile:homeNotFound'), 'Profile home not found', $id)
        else
    
    (: since the original "make_xsl.xsl" makes use of xsl:result-document 
       (which does not work in exist-db) we have to make some exist-db-specific 
       adjustments to it :)
    let $make_xsl := if (doc-available($config:make_xsl)) then doc($config:make_xsl) else ()
    let $make_xsl_existdb as document-node() := 
        let $tr := transform:transform($make_xsl, doc($config:prep_make_xsl_existdb), ())
        return doc(xmldb:store($config:xsls, "make_xsl_existdb.xsl", $tr))
    let $stylesheets := transform:transform($profile, $make_xsl_existdb, ())
    return 
        for $s in $stylesheets
        let $filename :=  $s/@xml:id||".xsl"
        return (
            xmldb:store($profile-home, $filename, $s),
            sm:chown(xs:anyURI($profile-home||"/"||$filename), $config:admin-user)
        )
};

(: getter function for specific profile settings :)
declare function profile:value($profile as element(profile), $value-name as xs:string){
    switch($value-name)
        case "name" return $profile/about/name/text()
        default return ()
};