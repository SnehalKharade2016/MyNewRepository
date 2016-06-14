global class AutoFreezeuserAccountBatch implements Database.Batchable<sObject> {
    
    public String QueryString;
    
	  public AutoFreezeuserAccountBatch(String qString) {
	    QueryString = qString ;
	  }
  
	  global Database.Querylocator start(Database.BatchableContext BC){ 
	    	//system.debug('start method called---------');      
	        return Database.getQueryLocator(QueryString);
	    }
    
	    global void execute (Database.BatchableContext BC, List<sObject> scope){  
	        List<User> listUserToBeAlert = new List<User>();
	        List<User> listUserToResetCounter = new List<User>();
	        List<User> listActiveUser = (List<User>)scope;
	        List<User> listUserTobeUpdated = new List<User>();
	        Integer noOfDays , noOfMonths;
	        Boolean isMonthSelected;
	        Set<Id> setUserId = new Set<Id>();
	        Map<Id , UserLogin> mapUserLogin = new Map<Id , UserLogin>();
	        AutoFreeze_User_Configuration__c autoFreezeUserSetting = AutoFreeze_User_Configuration__c.getOrgDefaults();
	        if(autoFreezeUserSetting != NULL && (autoFreezeUserSetting.User_not_Logged_in_Since_Last__c != NULL || autoFreezeUserSetting.User_not_Logged_in_Since_Last__c.length() != 0)) {
	        	String strDWM = autoFreezeUserSetting.User_not_Logged_in_Since_Last__c.substring(autoFreezeUserSetting.User_not_Logged_in_Since_Last__c.length()-1 , autoFreezeUserSetting.User_not_Logged_in_Since_Last__c.length());
	        	if(!(strDWM.equalsIgnoreCase('d')) && !(strDWM.equalsIgnoreCase('w')) && !(strDWM.equalsIgnoreCase('m'))) {
	        		noOfMonths = 1;
	        	}
	        	else if(strDWM.equalsIgnoreCase('d')) {
	        		noOfDays = Integer.valueOf(autoFreezeUserSetting.User_not_Logged_in_Since_Last__c.removeEnd('d'));
	        		isMonthSelected = false;
	        	}
	        	else if(strDWM.equalsIgnoreCase('w')) {
	        		noOfDays =  Integer.valueOf(autoFreezeUserSetting.User_not_Logged_in_Since_Last__c.removeEnd('w')) * 7;
	        		isMonthSelected = false;
	        	}
	        	else if(strDWM.equalsIgnoreCase('m')) {
	        		noOfMonths = Integer.valueOf(autoFreezeUserSetting.User_not_Logged_in_Since_Last__c.removeEnd('m'));
	        		isMonthSelected = true;
	        	}
	        }
	        for(User userObj : listActiveUser) {
	            //system.debug('userObj ----------------'+userObj.LastLoginDate);
	            if(userObj.LastLoginDate != null) {
	            	if(!isMonthSelected) {
	            		Date loginDate = userObj.LastLoginDate.date();            
			            if(loginDate.daysBetween(Date.today()) > noOfDays) {
			                listUserToBeAlert.add(userObj) ;
			            }
			            else {
			                listUserToResetCounter.add(userObj);
			            }
			            setUserId.add(userObj.Id);
	            	}
	            	else {
	            		Date expiryDate = userObj.LastLoginDate.date().addMonths(noOfMonths).addDays(1);  
	            		if(Date.today() == expiryDate) {
	            			 listUserToBeAlert.add(userObj) ;
	            		}
	            		else {
			                listUserToResetCounter.add(userObj);
			            }
			            setUserId.add(userObj.Id);
	            	}
	            }
	        }
	        
	        for(UserLogin userLoginObj : [select Id, UserId, IsFrozen from UserLogin where UserId IN : setUserId]) {
	            mapUserLogin.put(userLoginObj.UserId , userLoginObj);
	        }
	        
	        for(User userObj : listUserToBeAlert) {        
	            if(userObj.Counter__c == 0) {
	              userObj.Counter__c = userObj.Counter__c + 1;
	            }
	            else if(userObj.Counter__c == 1){
	              userObj.Counter__c = userObj.Counter__c + 1;
	            }
	            else if(userObj.Counter__c == 2) {
	              userObj.Counter__c = userObj.Counter__c + 1;
	            }
	            else if(userObj.Counter__c == 3) {
	              userObj.Counter__c = userObj.Counter__c + 1;
	            }
	            listUserTobeUpdated.add(userObj);   
	      }
	      for(User userObj : listUserToResetCounter ) {
	          if(mapUserLogin.containsKey(userObj.Id)) {
	            if(!mapUserLogin.get(userObj.Id).IsFrozen && userObj.Counter__c != 0) {
	                userObj.Counter__c = 0;
	            }
	          }
	        listUserTobeUpdated.add(userObj);   
	      }
	      try {  
	            Database.SaveResult[] UpdatedResult =  Database.Update(listUserTobeUpdated, false);
	            for(Database.SaveResult sr:UpdatedResult){
	              if(!sr.isSuccess()){
	                Database.Error err = sr.getErrors()[0];
	                System.debug('errors-----------'+err);
	              }
	            }
	        }
	        catch(Exception e){          
	            System.debug('Exception caught while Updating records----'+e);
	        }
	        
	    } 
	    
	    global void finish(Database.BatchableContext BC){
	           system.debug('finish method called---------'); 
	    }
}