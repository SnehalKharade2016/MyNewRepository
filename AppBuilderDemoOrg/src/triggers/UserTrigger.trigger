trigger UserTrigger on User (before update , after update) {
	
	UserTriggerHandler userTriggerHandlerObject = new UserTriggerHandler();
	AutoFreeze_User_Configuration__c autoFreezeUserSetting = AutoFreeze_User_Configuration__c.getOrgDefaults();
	if(autoFreezeUserSetting != NULL && !(autoFreezeUserSetting.Disable_User_Trigger__c)) {
		if(Trigger.isAfter && Trigger.isUpdate){
			userTriggerHandlerObject.sendAlertsToUser(Trigger.new, Trigger.oldMap);
		}
		
		if(Trigger.isBefore && Trigger.isUpdate) {
			userTriggerHandlerObject.resetCounterValue(Trigger.new, Trigger.oldMap);
		}
	}
	
}