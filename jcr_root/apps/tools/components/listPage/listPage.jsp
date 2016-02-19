
<%@page import="java.util.Date"%><%@include file="/libs/foundation/global.jsp"%><%
%><%@ page import="java.util.Iterator,
        com.day.cq.wcm.api.PageFilter,
        com.day.cq.wcm.api.Page,
        java.util.Calendar,
        java.util.ArrayList,
        java.util.Collections,
        com.day.cq.wcm.api.PageManager, com.day.cq.wcm.api.WCMMode, com.day.cq.wcm.commons.WCMUtils" %>
        
<%@include file="/libs/foundation/global.jsp"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">

<%@page import="com.day.cq.widget.HtmlLibraryManager"%><html>
    <head>
        <title>List Modified Pages</title>
        <meta http-equiv="Content-Type" content="text/html; utf-8"/>
        <%
            HtmlLibraryManager htmlMgr = sling.getService(HtmlLibraryManager.class);
            if (htmlMgr != null) {
                htmlMgr.writeCssInclude(slingRequest, out, "cq.widgets");
                htmlMgr.writeJsInclude(slingRequest, out, "cq.widgets");
            } 
        %>
        <script type="text/javascript" src="/apps/tools/components/listPage/js/listPage.js" ></script>
        <script src="/libs/cq/ui/resources/cq-ui.js" type="text/javascript"></script>
        <style type="text/css">
        #treeProgress {
            display: block;
            background-color: white;
            width:100%;
            min-height:400px;
            height:100%;
            border: 1px solid #888888;
            overflow: scroll;
            overflow-x: auto;  
        }
    </style>
        
</head>
<body>
    <h1 align="center">List Pages</h1>
    <form target="treeProgress" action="<%= resource.getPath() %>.html" method="POST" id="treeProgress_form">
    <input type="hidden" id="listroot" name="listroot" value="/content">
    <table class="form">
        <tr>
            <td>Start Path:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td><div id="path">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div><br>
                <small>Select location to activate</small>
            </td>
        </tr>
        <input type="hidden" id="date" name="date">
        <tr>
            <td>Date:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td><div id="dateField">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div><br>
                <small>Select Date</small>
            </td>
        </tr>
     
     
     
        <tr>
            <td></td>
            <td>
               <input type="button" value="Submit" onclick="document.getElementById('treeProgress_form').submit();">
            </td>
        </tr>
    </table>
</form><br>
    <iframe name="treeProgress" id="treeProgress">
    </iframe>
        <script>
            // provide a path selector field with a repository browse dialog
            CQ.Ext.onReady(function() {
            	 var DATETIME_FORMAT = "Y-m-d\\TH:i:s.000-04:00";
                var w = new CQ.form.PathField({
                    //"applyTo": "path",
                    renderTo: "CQ",
//                    "content": "/content",
                    rootPath: "/",
                    predicate: "hierarchy",
                    hideTrigger: false,
                    showTitlesInTree: false,
                    //name: "fakePathField",
                    value: "/content",
                    width: 400,
                    allowBlank:false,
                    typeAhead:true,
                    listeners: {
                        render: function() {
                            this.wrap.anchorTo("path", "tl");
                        },
                        change: function (fld, newValue, oldValue) {
                            document.getElementById("listroot").value = newValue;
                        },
                        dialogselect: function(fld, newValue) {
                            document.getElementById("listroot").value = newValue;
                        }
                    }
                });

                var d = new CQ.form.DateTime({
                	//"applyTo": "path",
                    renderTo: "CQ",
                    allowBlank: false,
                    hiddenFormat:DATETIME_FORMAT,
                    valueAsString:true, 
                    listeners: {
                        render: function() {
                            this.wrap.anchorTo("dateField", "tl");
                        },
                        change: function (fld, newValue, oldValue) {
                            document.getElementById("date").value = newValue;
                        },
                        dialogselect: function(fld, newValue) {
                            document.getElementById("date").value = newValue;
                        }
                    }

                });


                
            });
        </script>
</body>
</html>

   
