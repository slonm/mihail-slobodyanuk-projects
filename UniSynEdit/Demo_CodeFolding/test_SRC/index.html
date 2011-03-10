<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
    <title>Информация о сообщениях за период</title>

    <meta http-equiv="content-type" content="text/html;charset=utf-8" />
    <meta http-equiv="Content-Style-Type" content="text/css" />
    
    <meta name="description" content="Информация о сообщениях" />
    <meta name="keywords" content="jqGrid, javascript, jquery" />
    
    <link rel="stylesheet" type="text/css" media="screen" href="themes/basic/grid.css" />
    <link rel="stylesheet" type="text/css" media="screen" href="themes/jqModal.css" />
    <link rel="stylesheet" type="text/css" media="screen" href="main.css" />
</head>
<body>
    <table id="list" class="scroll"></table> 
    <div id="pager" class="scroll" style="text-align:center;"></div>
    
    <table id="list10_d"></table>
    <div id="pager10_d"></div>

<a href="javascript:void(0)" id="ms1">Get Selected id's</a>

    <script type="text/javascript" src="jquery-1.3.2.min.js"></script>
    <script type="text/javascript" src="jquery.jqGrid.js"></script>
    <script type="text/javascript" src="jquery.jqGrid-min.js"></script>
    <script type="text/javascript" src="js/min/jqDnR-min.js"></script>
    <script type="text/javascript">
    jQuery(document).ready(function(){
        var lastSel;
        jQuery("#list").jqGrid({
            url:'getdata.php?q=3',
            datatype: 'json',
            mtype: 'POST',
            colNames:['#', 'Дата/время', 'Имя журнала', 'Отправитель', 'Ид.', 'Категория', 'Тип', 'Источник', 'Повторений', 'Сообщение', 'Номер записи', 'q'],
            colModel :[
                {name:'id', index:'id', width:30}
                ,{name:'DateTimeGenerated', index:'DateTimeGenerated', width:150, align:'right', editable:true, edittype:"datetime"}
                ,{name:'EventLogName', index:'EventLogName', width:90, editable:true, edittype:"text"}
                ,{name:'ComputerName', index:'ComputerName', width:80, editable:true, edittype:"text"}
                ,{name:'EventID', index:'EventID', width:40, editable:true, edittype:"text"}
                ,{name:'Category', index:'Category', width:40, editable:true, edittype:"text"}
                ,{name:'EventType', index:'EventType', width:80, editable:true, edittype:"text"}
                ,{name:'Source', index:'Source', width:120, editable:true, edittype:"text"}
                ,{name:'MsgReiterations', index:'MsgReiterations', width:80,editable:true, edittype:"text"}
                ,{name:'Message', index:'Message', width:280,  editable:true, sortable:false}
                ,{name:'RecordNumber', index:'RecordNumber', width:80, editable:true, edittype:"text"}
                ,{name:'q', index:'q', width:80, editable:true, edittype:"text"}
                ],
            autowidth: true,
            pager: jQuery('#pager'),
            rowNum:25,
            rowList:[25,50,100],
            sortname: 'id',
            sortorder: "asc",
            viewrecords: true,
            rownumbers: true,
            height: 530,
            imgpath: 'themes/basic/images',
            caption: 'Информация о сообщениях',
            pginput: true,
            pgbuttons: true,
            	footerrow : true,
	userDataOnFooter : true,
	altRows : true,
        multiselect: false,
        onSelectRow: function(ids) {
		if(ids == null) {
			ids=0;
			if(jQuery("#list10_d").jqGrid('getGridParam','records') >0 )
			{
				jQuery("#list10_d").jqGrid('setGridParam',{url:"getdata.php?q="+ids,page:1});
				jQuery("#list10_d").jqGrid('setCaption',"Invoice Detail: 12")
				.trigger('reloadGrid');
			}
		} else {
			jQuery("#list10_d").jqGrid('setGridParam',{url:"getdata.php?q="+ids,page:1});
			jQuery("#list10_d").jqGrid('setCaption',"Invoice Detail: 13")
			.trigger('reloadGrid');			
		}
            }
        });
    jQuery("#list").navGrid('#pager',{edit:false,add:false,del:false,refresh:true,find:false});
    /*jQuery("#list").jqGrid('gridResize',{minWidth:350,maxWidth:800,minHeight:80, maxHeight:580});
              */
jQuery("#list10_d").jqGrid({
	height: 100,
   	url:'subgrid.php?q=1&id=0',
	datatype: "json",
   	colNames:['No','Item', 'Qty', 'Unit','Line Total'],
   	colModel:[
   		{name:'num',index:'num', width:55},
   		{name:'item',index:'item', width:180},
   		{name:'qty',index:'qty', width:80, align:"right"},
   		{name:'unit',index:'unit', width:80, align:"right"},		
   		{name:'linetotal',index:'linetotal', width:80,align:"right", sortable:false, search:false}
   	],
   	rowNum:5,
   	rowList:[5,10,20],
   	pager: '#pager10_d',
   	sortname: 'item',
    viewrecords: true,
    sortorder: "asc",
	multiselect: true,
	caption:"Invoice Detail"
}).navGrid('#pager10_d',{add:false,edit:false,del:false});
    jQuery("#ms1").click( function() {
	var s;
	s = jQuery("#list10_d").jqGrid('getGridParam','selarrrow');
	alert(s);
});
    
});

    </script>
</body>
</html>