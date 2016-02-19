CQ.wcm.listPage = CQ.Ext.extend(CQ.Ext.Panel, {


    constructor : function(config) {
        config = (!config ? {} : config);

        var defaults = {
            "hideBorders" :true,
            "renderTo" :"listPageDashboard",
            "border" :false,
            "stateful" :false,
            "layout" :"border",
            "frame" :true,
            "height" :150

        };
        CQ.Util.applyDefaults(config, defaults);
        // init component by calling super constructor
        CQ.wcm.listPage.superclass.constructor.call(this, config);
    },

    initComponent : function() {
        CQ.wcm.listPage.superclass.initComponent.call(this);
        var currentObj = this;
        this.leftSidePanel = new CQ.Ext.FormPanel(this.leftSidePanelConfig());
        this.add(this.leftSidePanel);

    },

    onRender : function(ct, position) {
        CQ.wcm.listPage.superclass.onRender.call(this, ct, position);

    },

    leftSidePanelConfig : function() {

        var curr = this;
        var config = {
            title :"",
            region :'center',
            //url :'/apps/tools/components/listPage',
            //method :'POST',
            frame :true,
            autoHeight :true,
            // bodyStyle :'padding: 10px 10px 0 10px;',
            labelWidth :80,
            defaults : {
                anchor :'95%',
                allowBlank :false,
                msgTarget :'side'
            },
            width :390,
            height :400,
            items : [
            
             {
                id :'date',
               // store :this.pageStore,
                name :'date',
                xtype :'datetime',
                fieldLabel :'Select Date',
                allowBlank :false
            }, 
            {
                id :'listroot',
               // store :this.pageStore,
                name :'listroot',
                xtype :'pathfield',
                fieldLabel :'Path of list Root',
                typeAhead :true,
                value : ""
                
            } ],
            buttons : [ {
                text :'Submit',
                
                handler : function() {
            	
            	
    	        curr.leftSidePanel.getForm().submit({
    	        	url : '/apps/tools/components/listPage',
                	method:'POST',
    	        	success:function(action,result){
    	        	//CQ.Ext.MessageBox.alert('Confirm');
    	        		CQ.Ext.fly('result').update(result.result);
    	        	
    	        	},
    	        	error:function(action,result){
    	        		CQ.Ext.fly('result').update(result.result);
    	        	}
    	        });


                }
            } ]
        }

        config = CQ.Util
                .applyDefaults(this.initialConfig.leftSidePanel, config)

        return config;
    }
});
CQ.Ext.reg("listPage", CQ.wcm.listPage);