xquery version "3.0";

module namespace app="http://acdh.oeaw.ac.at/apps/xtoks/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://acdh.oeaw.ac.at/apps/xtoks/config" at "config.xqm";
import module namespace profile="http://acdh.oeaw.ac.at/apps/xtoks/profile" at "profile.xqm";

(:~
 : Populates a selectbox with the available profiles.
 : 
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:profiles($node as node(), $model as map(*)) {
    for $p in collection($config:profiles)//profile
    return <option value="{$p/@id}" xmlns="http://www.w3.org/1999/xhtml">{profile:value($p, "name")}</option>
};