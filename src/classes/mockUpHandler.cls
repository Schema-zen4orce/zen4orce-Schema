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
            if(res.isCreateable() && res.isUpdateable())
            objects.add(new selectOption(res.getName(),res.getLabel()));
        }
        return objects;  
    }
    public blob generateCSV()
    {
        List<FieldTypeDetails__mdt> lstCSVNameMetadata =new List<FieldTypeDetails__mdt>([select CSVColumnName__c from FieldTypeDetails__mdt]);
        String csvFileString=''; 
		for(FieldTypeDetails__mdt  csvColumnName: lstCSVNameMetadata){  
        	csvFileString += '	'+ csvColumnName.CSVColumnName__c.replace(',','	');
        } 
        csvFileString = csvFileString.trim();
		Blob csvBlob = Blob.valueOf(csvFileString);
        return csvBlob;
   	}
}
