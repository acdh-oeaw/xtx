xquery version "3.0";

import module namespace xdb="http://exist-db.org/xquery/xmldb";
import module namespace sm="http://exist-db.org/xquery/securitymanager";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

(: setui on rest endpoints :)
(sm:chmod(xs:anyURI($target||"/modules/rest.xqm"), "rwSrwxr-x"),
(: setui on updateProfile.xql :)
sm:chmod(xs:anyURI($target||"/modules/updateProfile.xql"), "rwSrwxr-x"))