public class mockUpHandler {
 
    public List<SelectOption> allObjects()
    {
        map<String,schema.SObjectType> globalDescribe=schema.getGlobalDescribe();
        List<String> objList=new List<String>();
        List<SelectOption> objects=new List<SelectOption>();
        objList.addAll(globalDescribe.keySet());
        Schema.DescribeSObjectResult[] results= Schema.DescribeSObjects(objList);
		objects.add(new selectOption('Select','Select'));
        for(Schema.DescribeSObjectResult res:results){
            if(res.isCreateable() && res.isqueryable() && !res.isCustomSetting() && res.getRecordTypeInfos().size()>0 )
            objects.add(new selectOption(res.getName(),res.getName()));
        }
        return objects;  
    }
    public String generateCSV()
    {
        List<FieldTypeDetails__mdt> lstCSVNameMetadata =new List<FieldTypeDetails__mdt>([select CSVColumnName__c from FieldTypeDetails__mdt]);
        String csvFileString=''; 
		for(FieldTypeDetails__mdt  csvColumnName: lstCSVNameMetadata){  
        	csvFileString += '	'+ csvColumnName.CSVColumnName__c.replace(',','	');
        } 
        csvFileString = csvFileString.trim();
		Blob csvBlob = Blob.valueOf(csvFileString);
        System.debug('String'+csvFileString);
        return csvFileString;
   	}
    public String generateHelp()
    {
    	List<FieldTypeDetails__mdt> lstCSVNameMetadata =new List<FieldTypeDetails__mdt>([select CSVColumnName__c,DataType__c,Description__c from FieldTypeDetails__mdt]);
        String csvFileString=''; 
        system.debug('Help');
        csvFileString +=  'CSVColumnName'+'\\t';
        csvFileString +=  'DataType'+'\\t';
        csvFileString +=  'Description'+'\\n';
		for(FieldTypeDetails__mdt  csvColumnName: lstCSVNameMetadata){  
        	csvFileString += csvColumnName.CSVColumnName__c.replace(',','')+'\\t';
        	csvFileString += csvColumnName.DataType__c.replace(',','')+'\\t';
        	csvFileString += csvColumnName.Description__c.replace(',','	')+'\\n';
        }
        //system.debug('Help csv'+csvFileString); 
        csvFileString = csvFileString.trim();
        return csvFileString;
    }
}