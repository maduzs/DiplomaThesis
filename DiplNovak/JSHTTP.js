var JSHTTP = function() {
    
    var xmlhttp;
    
    this.init = function(){
        JS_COMMUNICATOR.sendResponse("jshttp: init");
    }
    
    this.eval = function(param, param2) {
        xmlhttp=null;
        if (window.XMLHttpRequest)
        {// code for all new browsers
            xmlhttp=new XMLHttpRequest();
        }
        else if (window.ActiveXObject)
        {// code for IE5 and IE6
            xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
        }
        if (xmlhttp!=null)
        {
            xmlhttp.onreadystatechange=state_Change;
            
            xmlhttp.open("GET","www.google.com",true);
            xmlhttp.send();
        }
        else
        {
            JS_COMMUNICATOR.sendResponse("Your browser does not support XMLHTTP.");
            //alert("Your browser does not support XMLHTTP.");
        }
    }
    
    function state_Change(e)
    {
        
        JS_COMMUNICATOR.sendResponse("state " + xmlhttp.readyState);
        if (xmlhttp.readyState==4)
        {// 4 = "loaded"
            if (xmlhttp.status==200)
            {// 200 = OK
                //xmlhttp.data and shtuff
                // ...our code here...
                
                JS_COMMUNICATOR.sendResponse("OK");
            }
            else
            {
                
                JS_COMMUNICATOR.sendResponse("Problem retrieving data" + xmlhttp.status);
            }
        }
    }
    
    this.render = function(){
        var text =
        {
            "uiElements" : [
                            {"button": {
                            "objectId" : 0,
                            "title" : "button1",
                            "frame": {
                            "x" : 50,
                            "y" : 360,
                            "width" : 100,
                            "height" : 50
                            },
                            "onClick": "eval",
                            "params": [
                                       {"value" : "test"},
                                       {"value" : "test2"}
                                       ]
                            }
                            }
                            ]
        };
        JS_COMMUNICATOR.sendResponse(text);
    }
    
}

