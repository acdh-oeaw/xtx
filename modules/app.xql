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
declare function app:profiles-to-option($node as node(), $model as map(*)) {
    for $p in collection($config:profiles)//profile
    return <option value="{$p/@id}" xmlns="http://www.w3.org/1999/xhtml">{profile:value($p, "name")}</option>
};


(:~
 : Returns auto-generated documentation for RestXQ endponts.
 : 
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:profiles($node as node(), $model as map(*)) {
    let $module := inspect:inspect-module(xs:anyURI($config:app-root||"/modules/rest.xqm"))
    let $prefix := $module/@prefix
    let $rows := 
        for $ep at $p in $module//function[annotation/@namespace = 'http://exquery.org/ns/restxq']
            let $name := data($ep/substring-after(@name,$prefix||":")),
                $path := data($ep/annotation[@name='rest:path']/value),
                $method := data($ep/annotation[1]/substring-after(@name,'rest:')),
                $params := 
                    for $p in $ep/annotation[@name='rest:query-param']
                    let $name := $p/value[1]/data(.),
                        $default := $p/value[3]/data(.)
                    return <li xmlns="http://www.w3.org/1999/xhtml">{$name} (default "{$default}")</li>,
                $consumes := data($ep/annotation[@name='rest:consumes']/value),
                $produces := data($ep/annotation[@name='rest:produces']/value),
                $desc := data($ep/annotation[@name='tok:desc']/value)
            order by $path,$method[. = ("GET", "POST", "PUT", "DELETE")]
            return 
                <tr xmlns="http://www.w3.org/1999/xhtml">
                    <td>{$name}</td>
                    <td>{$desc}</td>
                    <td>{$method}</td>
                    <td>{"/exist/restxq"||$path}</td>
                    <td> 
                        <ul>{$params}</ul>
                    </td>
                    <td>{$consumes}</td>
                    <td>{$produces}</td>
                </tr>
    return 
        <table xmlns="http://www.w3.org/1999/xhtml" class="table">
            <thead>
                <th>Name</th>
                <th>Description</th>
                <th>HTTP Method</th>
                <th>Path</th>
                <th>Query Parameters</th>
                <th>Consumes</th>
                <th>Produces</th>
            </thead>
            <tbody>{$rows}</tbody>
        </table>
};