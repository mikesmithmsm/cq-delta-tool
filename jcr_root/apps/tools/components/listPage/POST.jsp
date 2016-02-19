
<%@page import="java.util.Date"%><%@include file="/libs/foundation/global.jsp"%><%
%><%@ page import="java.util.Iterator,
        com.day.cq.wcm.api.PageFilter,
        com.day.cq.wcm.api.Page,
        java.util.Calendar,
        java.util.ArrayList,
        java.util.Collections,com.day.text.Text,
        com.day.cq.wcm.api.PageManager, com.day.cq.wcm.api.WCMMode, com.day.cq.wcm.commons.WCMUtils, java.text.SimpleDateFormat" %>


<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.HashSet"%><html>
        
<body>
        
        
    <%
    //String docroot = currentDesign.getPath();
    Set<String> activatedPath  = new HashSet<String>();
    Set<String> modifiedPath  = new HashSet<String>();
    HttpSession session = request.getSession();
    String listroot = "/";
    if(request.getParameter("listroot")!=null){
    	listroot = request.getParameter("listroot");
    }
    
    //String listroot = properties.get("listroot", currentPage.getPath());
    String date = null;
    if(request.getParameter("date")!=null){
    date =  request.getParameter("date");
    //date = (Calendar) request.getParameter("date");
    
    }
    %><%
    if(listroot==null || "".equals(listroot) || date==null){
    out.println("Please select date and list root"); 
    
    }
   else{
	   String modifiedPagePathQuery = "/jcr:root"+listroot+"//element(*,nt:base)[@cq:lastModified > xs:dateTime('"+date+"') or @jcr:lastModified>xs:dateTime('"+date+"')]";
	   //out.println(modifiedPagePathQuery);
	   Iterator<Resource> iter = resourceResolver.findResources(modifiedPagePathQuery,"xpath");
	   out.println("<br>List of resources <b>Modified</b> under <b>"+ listroot +"</b>After <b>"+date+"</b></br>" );
	   while(iter.hasNext()){
		   Resource res = iter.next();
		   modifiedPath.add(res.getPath());
		   out.println("<br>"+res.getPath()+"</br>");
	   }
	   
	   String ActivatedPathQuery = "/jcr:root"+listroot+"//element(*,nt:base)[@cq:lastReplicated > xs:dateTime('"+date+"')]";
	   Iterator<Resource> iter2 = resourceResolver.findResources(ActivatedPathQuery,"xpath");
	   out.println("<br>-----------------------------------------------------------------------------------</br>");
       out.println("<br>List of resources <b>Activated</b> under <b>"+ listroot +"</b>After <b>"+date+"</b></br>" );
       while(iter2.hasNext()){
           Resource res = iter2.next();
           
           activatedPath.add(res.getParent().getPath());
           out.println("<br>"+res.getParent().getPath()+"</br>");
       }
       
       
       if(modifiedPath.size()>0){
           session.setAttribute("allModifiedPath",modifiedPath);
           out.println("<br><a href=\""+resource.getPath()+".createPackage.html\" target=\"_top\"> Click Here to create Package of Modified Item </a><br/>");
           
           
       }
       
       if(activatedPath.size()>0){
    	   session.setAttribute("allActivatedPages",activatedPath);
    	   out.println("<br><a href=\""+resource.getPath()+".Activate.html\" target=\"_top\"> Click Here to activate Item to different Agent </a></br>");
           
       }
	   
	   
   }%>
</body>
</html>