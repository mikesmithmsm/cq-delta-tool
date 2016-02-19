<%@page session="false" import="javax.jcr.*,
        com.day.cq.wcm.api.Page,
        com.day.cq.wcm.api.PageManager,
        org.apache.sling.api.resource.Resource,
        com.day.cq.wcm.commons.WCMUtils,
        com.day.cq.wcm.api.NameConstants,
        com.day.cq.wcm.api.designer.Designer,
        com.day.cq.wcm.api.designer.Design,
        com.day.cq.wcm.api.designer.Style,
        org.apache.sling.api.resource.ValueMap,
        com.day.cq.wcm.api.components.ComponentContext,
        com.day.cq.wcm.api.components.EditContext,
        java.util.Date, java.text.SimpleDateFormat, 
        java.text.FieldPosition, java.text.ParsePosition,
        java.util.Iterator,
        javax.jcr.Property,
        javax.jcr.Node,
        javax.jcr.PropertyType,
        javax.jcr.Session,
        com.day.cq.commons.jcr.JcrUtil,
        javax.jcr.PropertyIterator,
        com.day.cq.replication.ReplicationQueue,
        com.day.cq.replication.ReplicationQueue.Entry,
        java.util.Iterator,
        java.io.ObjectInputStream,
        java.io.ByteArrayInputStream,
        com.day.cq.replication.ReplicationContentFacade,
        org.apache.sling.api.resource.ResourceResolver,
        java.io.PrintWriter,
        javax.servlet.jsp.JspWriter" %><%
%><%@taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling/1.0" %><%
%><%@taglib prefix="cq" uri="http://www.day.com/taglibs/cq/1.0" %><%
%><%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %><%
%><%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%
%><%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%
%>
<%@include file="/libs/foundation/global.jsp"%>
<sling:defineObjects />
<%@page import="com.day.cq.packaging.CQPackageManager"%>
<%@page import="com.day.jcr.vault.packaging.PackageManager"%>
<%@page import="com.day.cq.wcm.siteimporter.ImporterContext"%>
<%@page import="com.day.jcr.vault.packaging.JcrPackageManager"%>
<%@page import="com.day.jcr.vault.packaging.PackagingService"%>
<%@page import="com.day.jcr.vault.fs.config.DefaultWorkspaceFilter"%>
<%@page import="com.day.jcr.vault.packaging.JcrPackage"%>
<%@page import="com.day.jcr.vault.fs.api.PathFilterSet"%>
<%@page import="com.day.jcr.vault.util.HtmlProgressListener"%>
<%@page import="org.osgi.framework.BundleContext"%>

<%@page import="org.apache.jackrabbit.util.Text"%>
<%@page import="com.day.cq.rewriter.linkchecker.LinkCheckerSettings"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.Set"%><html>
<head>
<title>package creation</title>
</head><body>

<%
Session sess = resourceResolver.adaptTo(Session.class);
BundleContext bundleContext = sling.getService(BundleContext.class);
//ImporterContext ctx = ImporterContext.createContext(slingRequest,slingResponse,bundleContext);
//Session sess = sling.getResolver().adaptTo(Session.class);
HttpSession session = request.getSession();
Set<String> allmodifiedPath = new HashSet<String>();
if(null!=session.getAttribute("allModifiedPath")){
	allmodifiedPath = (HashSet<String>)session.getAttribute("allModifiedPath");
}
String pkgGroupName = "CQSupportTool";
String packageName = request.getParameter("pkgName")!=null && !"".equals(request.getParameter("pkgName"))?request.getParameter("pkgName"):"ModifiedPagePackage";

JcrPackageManager packMgr = PackagingService.getPackageManager(sess);

// check if package already exists
String packPath = pkgGroupName + "/" + packageName + ".zip";
Node packages = packMgr.getPackageRoot();
if (packages.hasNode(packPath)) {
packages.getNode(packPath).remove();
packages.getSession().save();
}
CQPackageManager pckgManager = sling.getService(CQPackageManager.class);
JcrPackage pack = pckgManager.createPackage(sess,pkgGroupName,packageName);
pckgManager.ensureVersion(pack);
DefaultWorkspaceFilter filters = new DefaultWorkspaceFilter();
out.println("<br> Adding following filter path <br> ");
for(String path:allmodifiedPath){
    out.println(path);
     filters.add(new PathFilterSet(path));
}

pack.getDefinition().setFilter(filters, true);
packMgr.assemble(pack, null);
String serverName = (request.getProtocol().split("/")[0]).toLowerCase()+"://"+request.getServerName();
if(!"".equals(request.getServerPort())){
    serverName+=":"+request.getServerPort();
}

String docroot = serverName +"/crx/packmgr/service.jsp";
out.println("<br><br><strong>Package Creation Done with name "+ packageName +"</strong>");
%>
<form method="get" action="<%=docroot %>">
<input type="hidden" name="cmd" id="cmd" value="get"></input>
<input type="hidden" name="name" id="name" value="<%=Text.escape(packageName) %>"></input>
<input type="hidden" name="group" id="group" value="<%=Text.escape(pkgGroupName) %>"></input>
<input type="submit" value="Download Package"></input>
</form>
</body>
</html>