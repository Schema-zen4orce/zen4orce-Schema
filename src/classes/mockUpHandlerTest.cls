public with sharing class mockUpHandlerTest {
	//test a list of all objects
	public  static testmethod void testallObjects()
	{
		mockUpHandler mh=new mockUpHandler();		
		mh.allObjects();
	}	
	//test blob returned
	public  static testmethod void testgenerateCSV()
	{
		mockUpHandler mh=new mockUpHandler();
		mh.generateCSV();
	}
}