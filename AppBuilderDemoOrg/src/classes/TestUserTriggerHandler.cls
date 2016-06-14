/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class TestUserTriggerHandler {

    static testMethod void testAutoFreezeUserAccount() {
    	 List<User> listUsers = new List<User>();
         User userObj1 =  createUser('test11','testUser11@testuser.com','test11','test@test.com','testCity', 'System Administrator');
         listUsers.add(userObj1);
         User userObj2 =  createUser('test12','test1User12@testuser.com','test12','test1@test.com','testCity1' , 'System Administrator');
         listUsers.add(userObj2); 
         User userObj3 =  createUser('test13','test2User13@testuser.com','test13','test2@test.com','testCity2' , 'System Administrator');
         listUsers.add(userObj3);
         User userObj4 =  createUser('test134','test2User134@testuser.com','test13','test24@test.com','testCity2', 'System Administrator');
         listUsers.add(userObj4);
         
         try{
         	Test.startTest();
         	insert listUsers;
         	listUsers[0].Counter__c = 1;
         	listUsers[1].Counter__c = 2;
         	listUsers[2].Counter__c = 3;
         	listUsers[3].Counter__c = 4;
         	update listUsers;
         	AutoFreezeUserAccountScheduler.executeAutoFreezeBatch();
      	  	Test.stopTest();
         }
         catch(Exception e) {
         	system.debug('Exception caught while saving record : '+e.getMessage());
         }
         
         
    }
    
    private static User createUser(String LastName,String UserName,String Alias,String Email,String City, String strProfile){
        //query on Profile Where Profile Name System Admin
	      Profile sysAdmin = [Select Id from Profile where Name= : strProfile];
	      User testU1 = new User();
	      testU1.Username = UserName;
	      testU1.LastName = LastName;
	      testU1.Alias = Alias;
	      testU1.Email = Email;
	      testU1.LanguageLocaleKey = 'en_US';
	      testU1.LocaleSidKey = 'en_US';
	      testU1.EmailEncodingKey = 'ISO-8859-1';
	      testU1.TimeZoneSidKey = 'GMT';
	      testU1.City = City;
	      testU1.IsActive = true;
	      testU1.ProfileId = sysAdmin.Id;
	      //insert testU1;            
	      return testU1;
    }
}