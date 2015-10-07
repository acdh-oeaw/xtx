xquery version "3.0";

import module namespace xdb="http://exist-db.org/xquery/xmldb";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

declare function local:mkcol-recursive($collection, $components) {
    if (exists($components)) then
        let $newColl := concat($collection, "/", $components[1])
        return (
            xdb:create-collection($collection, $components[1]),
            local:mkcol-recursive($newColl, subsequence($components, 2))
        )
    else
        ()
};


declare variable $profile-config := <collection xmlns="http://exist-db.org/collection-config/1.0">
    <index xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <fulltext default="none" attributes="false"/>
    </index>
    <triggers>
        <trigger class="org.exist.collections.triggers.XQueryTrigger">
            <parameter name="url" value="xmldb:exist:///db/apps/xToks/modules/updateProfile.xql"/>
        </trigger>
    </triggers>
</collection>
;

(: Helper function to recursively create a collection hierarchy. :)
declare function local:mkcol($collection, $path) {
    local:mkcol-recursive($collection, tokenize($path, "/"))
};

(: store the collection configuration :)
local:mkcol("/db/system/config", $target),
xdb:store-files-from-pattern(concat("/system/config", $target), $dir, "*.xconf"),
local:mkcol("/db/system/config/"||$target, "xsl-tokenizer/profiles"),
xdb:store("/db/system/config/"||$target||"/xsl-tokenizer/profiles", "collection.xconf", $profile-config)