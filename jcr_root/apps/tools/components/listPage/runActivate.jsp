<%@page session="false"
        contentType="text/html"
        pageEncoding="utf-8"
        import="java.io.PrintWriter,
            java.util.Iterator,
            javax.jcr.Node,
            javax.jcr.RepositoryException,
            javax.jcr.Session,
            org.apache.jackrabbit.util.Text,
            org.apache.sling.api.resource.Resource,
            org.apache.sling.api.resource.ResourceMetadata,
            org.apache.sling.api.resource.ResourceResolver,
            org.apache.sling.api.scripting.SlingScriptHelper,
            org.slf4j.Logger,
            org.slf4j.LoggerFactory,
            com.day.cq.commons.LabeledResource,
            com.day.cq.dam.api.Asset,
            com.day.cq.replication.Agent,
            com.day.cq.replication.AgentManager,
            com.day.cq.replication.ReplicationActionType,
            com.day.cq.replication.ReplicationException,
            com.day.cq.replication.ReplicationQueue,
            com.day.cq.replication.ReplicationStatus,
            com.day.cq.replication.Replicator,
            com.day.cq.wcm.api.Page" %><%
%><%@taglib prefix="sling" uri="http://sling.apache.org/taglibs/sling/1.0" %><%
%><%@taglib prefix="cq" uri="http://www.day.com/taglibs/cq/1.0" %><%
%><cq:defineObjects /><%

    String excludePath = slingRequest.getParameter("path");
    String agentName = slingRequest.getParameter("agent");
    //String path = slingRequest.getParameter("path");
    boolean onlyMod = "true".equals(slingRequest.getParameter("onlymodified"));
    boolean ignDeact = "true".equals(slingRequest.getParameter("ignoredeactivated"));
    boolean reactivate = "true".equals(slingRequest.getParameter("reactivate"));
    boolean dryRun = "dryrun".equals(slingRequest.getParameter("cmd"));
    boolean nasty = "true".equals(slingRequest.getParameter("nasty"));
    
    Replicator repl = sling.getService(Replicator.class);
    //ReplicationOptions replicationOptions = sling.getService(ReplicationOptions.class);
%>
<%@page import="java.util.Set"%>
<%@page import="java.util.HashSet"%>
<%@page import="com.day.cq.replication.ReplicationOptions"%>
<%@page import="com.day.cq.replication.AgentIdFilter"%><html><head>
    <style type="text/css">
        div {
            font-family:arial,tahoma,helvetica,sans-serif;
            font-size:11px;
            white-space:nowrap;
        }
        .action {
            display: inline;
            width: 120px;
            float: left;
        }
        .error {
            color: red;
            font-weight: bold;
        }
        .title {
            display: inline;
            width: 150px;
            float: left;
            margin: 0 8px 0 0;
            overflow: hidden;
        }
        .activate {

        }
        .ignore {
            color: #888888;
        }
        .cf {
            color: #888888;
        }
        .path {
            display: inline;
            width: 100%;
        }

    </style>
    <script type="text/javascript">
        var started = false;

        function start() {
            started = true;
        }
        function stop() {
            started = false;
        }
        function isStarted() {
            return started;
        }
        function jump() {
            window.scrollTo(0, 100000);
        }
    </script>
</head>
<body bgcolor="white">
    <div>
    <%
        Processor p = new Processor(repl, slingRequest.getResourceResolver(), new PrintWriter(out), sling,agentName);
        p.setIgnoreDeactivated(ignDeact);
        p.setOnlyModified(onlyMod);
        p.setReactivate(reactivate);
        p.setDryRun(dryRun);
        HttpSession session = request.getSession();
        //Process Exclude Path
        Set<String> excludePaths = new HashSet<String>();
        if(null!=excludePath && !excludePath.equals("")){
            String[] split = excludePath.trim().split(",");
            for(String eachPath:split){
                excludePaths.add(eachPath);
            }
        }
        if(null!=session.getAttribute("allActivatedPages")){
        Set<String> alldeletedPath = (HashSet<String>)session.getAttribute("allActivatedPages");
        //Activate all deleted path
        for(String path:alldeletedPath){
            //Check if it is in exclude list
            boolean excludePathFound = false;
            for(String exludePath:excludePaths){
                if(path.startsWith(excludePath)){
                    excludePathFound = true;
                }
            }
            //Activate only if it is not in exlude path list
            if(!excludePathFound){
            p.process(path);
            }
        }
        
        }
    %></div>
</body>
</html><%!

    private static class Processor {

        /**
         * default logger
         */
        private static final Logger log = LoggerFactory.getLogger(Processor.class);

        private final Replicator replicator;
        
        private final SlingScriptHelper sling;

        private final ResourceResolver resolver;

        private final Session session;

        private final PrintWriter out;

        private boolean onlyModified;

        private boolean reactivate;

        private boolean ignoreDeactivated;

        private boolean dryRun;

        private int tCount;

        private int aCount;

        private long lastUpdate;
        
        private String agentName;

        private Processor(Replicator replicator, ResourceResolver resolver, PrintWriter out, SlingScriptHelper sling,String agentName) {
            this.replicator = replicator;
            this.resolver = resolver;
            this.out = out;
            this.session = resolver.adaptTo(Session.class);
            this.sling = sling;
            this.agentName = agentName;
        }

        public void setOnlyModified(boolean onlyModified) {
            this.onlyModified = onlyModified;
        }

        public void setReactivate(boolean reactivate) {
            this.reactivate = reactivate;
        }

        public void setIgnoreDeactivated(boolean ignoreDeactivated) {
            this.ignoreDeactivated = ignoreDeactivated;
        }

        public void setDryRun(boolean dryRun) {
            this.dryRun = dryRun;
        }

        public void process(String path) {
            if (path == null || path.length() == 0) {
                out.printf("<div class=\"error\">No start path specified.</div>");
                return;
            }
            // snip off all trailing slashes
            while (path.endsWith("/")) {
                path = path.substring(0, path.length() - 1);
            }
            // reject root and 1 level paths
            if (path.lastIndexOf('/') <= 0) {
                if (path.length() == 0) {
                    path = "/";
                }
                out.printf("<div class=\"error\">Cowardly refusing to tree-activate \"%s\"</div>", path);
                return;

            }
            Resource res = resolver.getResource(path);
            if (res == null) {
                out.printf("<div class=\"error\">The resource at '%s' does not exist.</div>", path);
                return;
            }

            out.printf("%n<script>start()</script>%n");
            String cmd = dryRun ? "Simulating" : "Starting";
            StringBuffer msg = new StringBuffer("all pages");
            String delim = " that are ";
            if (onlyModified) {
                msg.append(delim);
                delim = "and ";
                msg.append("modified ");
            }
            if (reactivate) {
                msg.append(delim);
                delim = "and ";
                msg.append("activated ");
            }
            if (ignoreDeactivated) {
                msg.append(delim);
                delim = "and ";
                msg.append("not deactivated");
            }
            out.printf("<strong>%s tree nice-activation for path \"%s\" of %s</strong><br>", cmd, path, msg);
            out.printf("<hr size=\"1\">%n");

            long startTime = System.currentTimeMillis();
            tCount = aCount = 0;
            try {
                process(res);
                long endTime = System.currentTimeMillis();
                out.printf("<hr size=\"1\"><br><strong>Activated %d of %d resources in %d seconds.</strong><br>",
                    aCount, tCount, (endTime-startTime)/1000);

            } catch (Exception e) {
                out.printf("<div class=\"error\">Error during processing: %s</div>", e.toString());
                log.error("Error during tree activation of " + path, e);
            }

            out.printf("%n<script>jump();stop();</script>%n");
            out.flush();
        }

        private Agent getThrottleAgent() {
            // get the first enabled agents
            AgentManager agentMgr = sling.getService(AgentManager.class);
            for (Agent agent: agentMgr.getAgents().values()) {
                if (agent.isEnabled() && agentName!=null && !"".equals(agentName) && agent.getId().trim().equals(agentName.trim())) {
                    return agent;
                }else{
                	if(agentName!=null && !"".equals(agentName) && agentName.equalsIgnoreCase("all")){
                		return agent;
                	}
                }
            }
            return null;
        }

        private boolean process(Resource res)
                throws RepositoryException, ReplicationException {

            // we can only tree-activate hierarchy nodes
            Node node = res.adaptTo(Node.class);
            if (!node.isNodeType("nt:hierarchyNode")) {
                return false;
            }
            Page page = res.adaptTo(Page.class);
            Asset asset = res.adaptTo(Asset.class);
            long lastModified;
            if (page != null) {
                lastModified = page.getLastModified() == null
                    ? -1
                    : page.getLastModified().getTimeInMillis();
            } else if (asset != null) {
                lastModified = asset.getLastModified() == 0
                    ? -1
                    : asset.getLastModified();
            }else {
                ResourceMetadata data = res.getResourceMetadata();
                lastModified = data.getModificationTime();
            }
            String title = Text.getName(res.getPath());
            LabeledResource lr = res.adaptTo(LabeledResource.class);
            if (lr != null && lr.getTitle() != null) {
                title = lr.getTitle();
            }
            ReplicationStatus rs = res.adaptTo(ReplicationStatus.class);
            long lastPublished = 0;
            boolean isDeactivated = false;
            boolean isActivated = false;
            if (rs != null && rs.getLastPublished() != null) {
                lastPublished = rs.getLastPublished().getTimeInMillis();
                isDeactivated = rs.isDeactivated();
                isActivated = rs.isActivated();
            }
            boolean isModified = lastModified > lastPublished;
            boolean doActivate = false;
            String action;
            if (!isModified && onlyModified) {
                doActivate = false;
                action = "Ignore (not modified)";
            } else if (!isActivated && reactivate) {
                action = "Ignore (not activated)";
            } else if (isDeactivated && ignoreDeactivated) {
                action = "Ignore (deactivated)";
            } else {
                action = "Activate";
                doActivate = true;
            }

            tCount++;

            Agent agent = getThrottleAgent();
            ReplicationQueue queue = agent == null ? null : agent.getQueue();
            int num= queue == null ? 0 : queue.entries().size();
            int test=0;
            
            while (num>0) {
                out.printf("<div class=\"action\">&nbsp;</div>");
                out.printf("<div class=\"title\">&nbsp;</div>");
                out.printf("<div class=\"path\">Queue of full (%d pending on '%s') [%d], waiting...</div><br>", num, agent.getId(), test);
                out.printf("<script>jump();</script>%n");
                out.flush();
                try { 
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                    // ignore
                }
                num=queue.entries().size();
                test++;
            } 
            
            if (doActivate) {
                if (!dryRun) {
                    try {
                    	ReplicationOptions replicationOptions = new ReplicationOptions();
                    	//If all is not selected just replicated to selcted agent
                    	if(agentName!=null && !"".equals(agentName) && !agentName.trim().equalsIgnoreCase("all")){
                    		   replicationOptions.setFilter(new AgentIdFilter(agent.getId()));
                    		   out.printf("<div class=\"error\">Replicating to Agent: %s</div>", agent.getId());
                    		   replicator.replicate(session, ReplicationActionType.ACTIVATE, res.getPath(),replicationOptions);
                    	}else{
                    		//Or replicate it every where
                    		replicator.replicate(session, ReplicationActionType.ACTIVATE, res.getPath());
                    	}
                        
                    } catch (ReplicationException e) {
                        out.printf("<div class=\"error\">Error during processing: %s</div>", e.toString());
                        log.error("Error during tree activation of " + res.getPath(), e);
                    }
                }
                aCount++;
            }
            // get classifier
            String cf = "";
            String delim = "(";
            if (isModified) {
                cf+= delim + "modified";
                delim = ", ";
            }
            if (isActivated) {
                cf+= delim + "activated";
                delim = ", ";
            }
            if (isDeactivated) {
                cf+= delim + "deactivated";
            }
            if (cf.length() > 0) {
                cf = "<span class=\"cf\">" + cf + ")</span>";
            }
            // print
            out.printf("<div class=\"action %s\">%s</div>", doActivate ? "activate" : "ignore", action);
            out.printf("<div class=\"title\">%s</div>", title);
            out.printf("<div class=\"path\">%s %s [%d]</div><br>", res.getPath(), cf, tCount);
            out.flush();
            long now  = System.currentTimeMillis();
            if (now - lastUpdate > 1000L) {
                lastUpdate = now;
                out.printf("<script>jump();</script>%n");
                out.flush();
            }
            //Here we don't want to activate all cheldren so commenting
            //Iterator<Resource> iter = resolver.listChildren(res);
            //while (iter.hasNext()) {
              //  process(iter.next());
            //}
            return true;
        }
    }
%>