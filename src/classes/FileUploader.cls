public class FileUploader 
{
    public static Boolean summaryPage{get;set;}
    public String base64Value{get;Set;}
    public String csvData{get;set;}
    public String helpData{get;set;}
    public List<FieldTypeDetails__mdt> lstFieldDetails{get;set;}
    public List<SelectOption> objList{get;set;}
    public String selectedObj{get;set;}
    public List<SObject> records{get;set;}
    Public List<String> fieldsCMT{get;set;}
    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    String[] filelines = new String[]{};
    String[] filecolumns = new String[]{};
    set<string> lstString ;
    List<string> lstMatchedColumns {get;set;}
    List<string> lstUnMatchedColumns {get;set;}
   	Map<string,Map<string,string>> mapCSV = new Map<string,Map<string,string>>();
   	
    public FileUploader(){
        getAllObjects();
        csvgen();
        fieldsTypeDetails();
    }
    public PageReference reDirect()
    {
        System.debug('Sjghd');
        map<String,schema.SObjectType> globalDescribe=schema.getGlobalDescribe();
        Schema.SObjectType so=globalDescribe.get(selectedObj);
        Schema.DescribeSObjectResult objectDescribeResult = so.getDescribe();
        String objPrefix=objectDescribeResult.getKeyPrefix();
        System.debug(objPrefix);
        PageReference pr=new PageReference('/'+objPrefix);
        pr.setRedirect(true);
        return pr;
    }
    public void fieldsTypeDetails(){    
        lstFieldDetails=new List<FieldTypeDetails__mdt>([select DeveloperName,ColumnAPIName__c,CSVColumnName__c,DataType__c,Description__c,Primary__c from FieldTypeDetails__mdt]);
    }
   	public void getAllObjects(){
        objList=new List<SelectOption>();
        mockUpHandler mh=new mockUpHandler();
        objList=mh.allObjects();
    }
    // For generateing sample template and help file
    public void csvgen(){
        mockUpHandler mh=new mockUpHandler();
        helpData=mh.generateHelp();
        csvData=templateData.parseJSONString();
    }
    // Function to check CSV is blank or not
    public Boolean checkBlankCSV(){
    	nameFile=contentFile.toString();
        filelines = nameFile.split('\n');
        if(filelines.size()<2){
            return false;
        }
      return true;  	     
    }
    //  CSV into MAP<FieldNameAPI,map<ColumnName,RowValue>> Format 
    public map<string,map<string,string>> csvToMap(){
        Map<string,string> innerMap ;
        Integer primaryColumnIndex;
        String primaryColumn;
        for(FieldTypeDetails__mdt ft : [select CSVColumnName__c from FieldTypeDetails__mdt where Primary__c='True']){	
        	primaryColumn = String.valueOf(ft.CSVColumnName__c);
        }
        nameFile=contentFile.toString();
        filelines = nameFile.split('\n');
        filecolumns = filelines[0].split(',');
        for(Integer i=0;i<filecolumns.size();i++){
            if(filecolumns[i].equals(primaryColumn)){
                primaryColumnIndex = i;
                break;
            }
        }
        //system.debug('primary Key Index'+primaryColumnIndex);
        for (Integer i=1;i<filelines.size();i++){
                String[] inputvalues = new String[]{};
                inputvalues = filelines[i].split(',');            
                lstString = new set<string>();
                innerMap = new Map<string,string>();
                for(Integer j=0;j<filecolumns.size();j++){
                	lstString.add(filecolumns[j].replaceAll( '\\s+', '')); 
                	innerMap.put(filecolumns[j].trim(),inputvalues[j]);
                }
                mapCSV.put(inputvalues[primaryColumnIndex],innerMap); // remove this harcoding [2] this will come from custom metadata indexed 
            }
            return  mapCSV; 
    }
    // Match CSV column with CMT 
    public Boolean matchedColumnsCSVandCMT(set<string> defineCSVColumnNames){
    	lstMatchedColumns = new List<string>();
        lstUnMatchedColumns = new List<string>();
        for (String columns : lstString) {
    		if (defineCSVColumnNames.contains(columns)) {
        		lstMatchedColumns.add(columns);
    		} else {
        			lstUnMatchedColumns.add(columns);
    			}
			}         
        if(lstUnMatchedColumns.size()>0){
            return false;
        }
        return true;
    }
    // Check that all mandatory column are exist for given data types or not ** WIP 
    public Boolean mandatoryColumnCheck(set<string> defineCSVColumnNames,map<string,map<string,string>> mapCSV,map<string,string> mapAPIName){
    	set<String> setFieldType = new Set<String>();
    	 for(String fieldApi : mapCSV.keySet()){   
        	Map<String, String> innerMap1 = mapCSV.get(fieldApi);
        	for(String innermapkey : mapCSV.get(fieldApi).keySet()){
        		if(innermapkey==mapAPIName.get('type_x')){
        			 setFieldType.add(mapCSV.get(fieldApi).get(innermapkey));
        			/*columnValue  = mapCSV.get(fieldApi).get(innermapkey);
        				if(columnValue!=''){
        					mandFields = mapMandatoryFields.get(columnValue);
        					system.debug('columnValue values  '+columnValue);
        					system.debug('mand fields  '+mandFields);
                 			if(mandFields!=null){
                 			    lstMandatoryColumnNotexist = new List<string>();
                 				mapMandatoryColumnNotexist = new Map<string,List<String>>();
                 				lstMandatoryColumnexist = new List<string>();
                 				for (String columns : mandFields.split(',')) {
    								if (lstString.contains(mapAPIName.get(columns))) {
    								}else{
        								lstMandatoryColumnNotexist.add(mapAPIName.get(columns));
    								  }
								} 
                 			}
                 			if(lstMandatoryColumnNotexist.size()>0)
                 			mapMandatoryColumnNotexist.put(columnValue,lstMandatoryColumnNotexist);
                 			if(mapMandatoryColumnNotexist.size()>0)
                 			{
                 				errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.MandatoryColumnNotExist+mapMandatoryColumnNotexist);
            									ApexPages.addMessage(errormsg);
            									return null;
                 			}
        			} */	
        		} 
        	}
    	 }
    	 return true;
    }
     
    public Pagereference readFile()
    {
      	summaryPage=true; 
        String objName = selectedObj;
    	 ApexPages.Message errormsg ;
        // check If CSV is Blank then no need go further return from here 
        if(checkBlankCSV()==false){
        	errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.Blank_CSV);
            ApexPages.addMessage(errormsg);
        	return null;
        }
 		// SET contains all Predeifuned columns in metadata 
        Set<string> defineCSVColumnNames = new set<string>();
        for(FieldTypeDetails__mdt ft : [select CSVColumnName__c from FieldTypeDetails__mdt]){	
        	defineCSVColumnNames.add(String.valueOf(ft.CSVColumnName__c));
        }
        // Map for Mandatory fields for field type
        Map<string,string> mapMandatoryFields = new Map<string,string>();
        for(MandatoryColumns_FiledTypeWise__mdt mf : [select MasterLabel,MandatoryFields__c from MandatoryColumns_FiledTypeWise__mdt ]){
        	mapMandatoryFields.put(mf.MasterLabel,mf.MandatoryFields__c);
        } 
        // Map for column name and their data type
 		Map<string,string> mapFieldDataType = new Map<string,string>();
        for(FieldTypeDetails__mdt ftDetails : [select CSVColumnName__c,DataType__c from FieldTypeDetails__mdt ]){
        	mapFieldDataType.put(ftDetails.CSVColumnName__c,ftDetails.DataType__c);
        }
        
         map<String,String> mapAPIName=new map<String,String>();
         for(FieldTypeDetails__mdt mappedColumn1 : [select CSVColumnName__c,ColumnAPIName__c from FieldTypeDetails__mdt]){
                mapAPIName.put(mappedColumn1.ColumnAPIName__c.trim(), mappedColumn1.CSVColumnName__c.trim());
        	}
        // Get CSV data into map in map<FieldAPIName,map<columnName,rowValue>> format 
        Map<string,map<string,string>> mapCSV = csvToMap();
        // Match CSV and custom metadata column names 
        if(matchedColumnsCSVandCMT(defineCSVColumnNames)==false){
        	errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.ColumnNameNotValid+lstUnMatchedColumns);
            ApexPages.addMessage(errormsg);
        	return null;
        }
        // Check for mandatory Columns
        mandatoryColumnCheck(defineCSVColumnNames,mapCSV,mapAPIName);
        
     List<string> lstMandatoryColumnNotexist = new List<string>();
     Map<string,List<String>> mapMandatoryColumnNotexist = new Map<string,List<String>>();
     List<string> lstMandatoryColumnexist = new List<string>();
     String columnValue='';
     String mandFields='';
        for(String fieldApi : mapCSV.keySet()){   
        	Map<String, String> innerMap1 = mapCSV.get(fieldApi);
        	for(String innermapkey : mapCSV.get(fieldApi).keySet()){
        		if(innermapkey==mapAPIName.get('type_x')){
        			columnValue  = mapCSV.get(fieldApi).get(innermapkey);
        				if(columnValue!=''){
        					mandFields = mapMandatoryFields.get(columnValue);
                 			if(mandFields!=null){
                 			    lstMandatoryColumnNotexist = new List<string>();
                 				mapMandatoryColumnNotexist = new Map<string,List<String>>();
                 				lstMandatoryColumnexist = new List<string>();
                 				for (String columns : mandFields.split(',')) {
    								if (lstString.contains(mapAPIName.get(columns))) {
    									String datatype = mapFieldDataType.get(mapAPIName.get(columns));
    									String value = innerMap1.get(mapAPIName.get(columns));
    									if(datatype=='Number'){
    										try{
                                                value = value.trim();
    											Integer iValue = Integer.valueOf(value);
    											} catch(Exception e){
    												errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.DataValidation+'columns '+columns+' Data '+value);
            										ApexPages.addMessage(errormsg);
            										return null;
    											}
    									}
    									if(datatype=='Boolean'){
    										system.debug('Bool Check');
    										if(value.equalsIgnoreCase('true')||value.equalsIgnoreCase('false')||value.equalsIgnoreCase(''))
    										Boolean bValue = Boolean.valueOf(value) ;
    										else{
    											errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.DataValidation+' '+columns +'Data '+value );
            									ApexPages.addMessage(errormsg);
            									return null;
    										}
    									}
    								}else{
        								lstMandatoryColumnNotexist.add(mapAPIName.get(columns));
    								  }
								} 
                 			}
                 			if(lstMandatoryColumnNotexist.size()>0)
                 			mapMandatoryColumnNotexist.put(columnValue,lstMandatoryColumnNotexist);
                 			if(mapMandatoryColumnNotexist.size()>0)
                 			{
                 				errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.MandatoryColumnNotExist+mapMandatoryColumnNotexist);
            									ApexPages.addMessage(errormsg);
            									return null;
                 			}
        			}	
        	}																	
        	 }
        }
       	CustomSchemaBuilder.CSVData(mapCSV,objName);
        return null;    
	}
}