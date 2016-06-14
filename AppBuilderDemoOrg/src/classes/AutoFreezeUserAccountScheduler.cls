global class AutoFreezeUserAccountScheduler implements Schedulable {
	
	//public static String CRON_EXP = '0 30 12 * * ?'; 
    //public static String JOB_NAME = 'Auto freeze User Account Scheduler By : '+UserInfo.getName()+ ' Dated On ' + system.now();
    global void execute(SchedulableContext sc) {
        system.debug('Inside scheduler class-----------');
        String queryString = 'Select u.Phone, u.Name, u.Profile.Name, u.MobilePhone, u.LastLoginDate, u.IsActive, u.Id, u.Email,u.Counter__c From User u where u.IsActive = true AND u.Profile.Name != \'System Administrator\'';
        AutoFreezeuserAccountBatch batchObj = new AutoFreezeuserAccountBatch(queryString);
        Database.executeBatch(batchObj);
    }
    
    global static void executeAutoFreezeBatch() {
    	String CRON_EXP = '0 0 14 * * ?'; 
    	String JOB_NAME = 'Auto freeze User Account Scheduler By : '+UserInfo.getName()+ ' Dated On ' + system.now();
    	system.schedule(JOB_NAME , CRON_EXP , new AutoFreezeUserAccountScheduler());
    }
}