trigger DepertmentTrigger on Department__c (after insert, after update) {
	DepartmentTriggerHandler deptHandler = new DepartmentTriggerHandler();
	if(Trigger.isAfter && Trigger.isInsert) {
		//deptHandler.updatePositionOwnerFeildOnInsert(Trigger.New);
	}
	if(Trigger.isAfter && Trigger.isUpdate) {
		//deptHandler.updatePositionOwnerOnUpdate(Trigger.New, Trigger.oldMap);
	}
}