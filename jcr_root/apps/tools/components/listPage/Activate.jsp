<%--
  Copyright 1997-2008 Day Management AG
  Barfuesserplatz 6, 4001 Basel, Switzerland
  All Rights Reserved.

  This software is the confidential and proprietary information of
  Day Management AG, ("Confidential Information"). You shall not
  disclose such Confidential Information and shall use it only in
  accordance with the terms of the license agreement you entered into
  with Day.

  ==============================================================================

  Tree Activation

  Implements the tree activation component.

--%><%@ page contentType="text/html"
             pageEncoding="utf-8"
             import="com.day.cq.wcm.foundation.Image,
    com.day.cq.wcm.api.components.DropTarget,
    com.day.cq.wcm.api.components.EditConfig,
    com.day.cq.wcm.commons.WCMUtils,
    com.day.cq.replication.Replicator,
    com.day.cq.replication.Agent,
    com.day.cq.replication.AgentConfig,
    com.day.cq.widget.HtmlLibraryManager,
    com.day.cq.wcm.api.WCMMode,
    com.day.cq.wcm.api.components.Toolbar,
    com.day.cq.replication.ReplicationQueue,
    com.day.cq.replication.AgentManager, java.util.Iterator" %><%
%><%@include file="/libs/foundation/global.jsp"%><%
    AgentManager agentMgr = sling.getService(AgentManager.class);

%><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">
<html>
<head>
    <title>Replicate Deleted Content</title>
    <meta http-equiv="Content-Type" content="text/html; utf-8" />
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
</body>
</html><html>
<body>
<h1>Activate Tree (Before running this make sure that test connections pass to all your enabled replication agent)</h1>

<form target="treeProgress" action="<%= resource.getPath() %>.runActivate.html" method="GET" id="treeProgress_form">
    <table class="form">
        <tr>
            <td><label for="path">Path you want to exclude from activation:</label></td>
            <td><input id="path" name="path" size="100" type="text"><br>
                <small>Select path you want to exclude for activation (Use comma for multiple paths)</small>
            </td>
        </tr>
        <tr>
            <td><label for="path">Agent Name:</label></td>
            <td>
            <select name="agent" id="agent">
            <%
            for (Agent agent: agentMgr.getAgents().values()) {
                if (agent.isEnabled()) {
            %>
            <option value="<%=agent.getId() %>"><%=agent.getId()%></option>
            <% 
            }
            }
            
            %>
            <option value="all">all</option>
            </select>
            
            <br>
                <small>Agent should be selected based on previous selection, select all if you want to activate it to all replication agent</small>
            </td>
        </tr>
        
        
        <tr>
            <td></td>
            <td>
                <input id="onlymodified" name="onlymodified" type="checkbox" value="true">
                <label for="onlymodified">Only Modified</label>
            </td>
        </tr>
        <tr>
            <td></td>
            <td>
                <input id="reactivate" name="reactivate" type="checkbox" value="true">
                <label for="reactivate">Only Activated</label>
            </td>
        </tr>
        <tr>
            <td></td>
            <td>
                <input id="ignoredeactivated" name="ignoredeactivated" type="checkbox" checked value="true">
                <label for="ignoredeactivated">Ignore Deactivated</label><br>
            </td>
        </tr>
        <tr>
            <td></td>
            <td>
                <input type="hidden" name="cmd" value="dryrun" id="cmd">
                <input type="button" value="Dry Run" onclick="document.getElementById('cmd').value='dryrun'; document.getElementById('treeProgress_form').submit();">
                <input type="button" value="Activate" onclick="document.getElementById('cmd').value='activate'; document.getElementById('treeProgress_form').submit();">
                <a href="<%=resource.getPath() %>.html" target="_top">< Back to main Page</a>
            </td>
        </tr>
    </table>
</form>
<br>
<iframe name="treeProgress" id="treeProgress">
</iframe>

</body>
</html>
