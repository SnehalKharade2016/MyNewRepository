public with sharing class DepartmentTriggerHandler {
	
	public void updatePositionOwnerFeildOnInsert(List<Department__c> listDepartment) {
		List<Position__c> listPositionToUpdate = new List<Position__c>();
		for(Department__c deptObj : [Select d.OwnerId, d.Name, d.Id, 
											(Select Id, OwnerId, Name From Positions__r) 
									 From Department__c d 
									 Where d.Id IN : listDepartment]) {
			if(deptObj.Positions__r != NULL && deptObj.Positions__r.size() > 0) {
				for(Position__c positionObj : deptObj.Positions__r)  {
					positionObj.OwnerId = deptObj.OwnerId;
					listPositionToUpdate.add(positionObj);
				}
			}						 	
		}
		if(listPositionToUpdate != NULL && listPositionToUpdate.size() > 0) {
			try {
				database.update(listPositionToUpdate, false);
			}
			catch(Exception e) {
				system.debug('Exception caught while updating records-----------'+e);
			}
		}
	}
	
	public void updatePositionOwnerOnUpdate(List<Department__c> listNewDepartment , Map<Id , Department__c> mapOldDepartment) {
		List<Position__c> listPositionToUpdate = new List<Position__c>();
		Set<Id> setDepartmentIds = new Set<Id>();
		for(Department__c deptObj : listNewDepartment) {
			if(deptObj.OwnerId != mapOldDepartment.get(deptObj.Id).OwnerId) {
				setDepartmentIds.add(deptObj.Id);
			}
		}
		
		for(Department__c deptObj : [Select d.OwnerId, d.Name, d.Id, 
											(Select Id, OwnerId, Name From Positions__r) 
									 From Department__c d 
									 Where d.Id IN : setDepartmentIds]) {
			if(deptObj.Positions__r != NULL && deptObj.Positions__r.size() > 0) {
				for(Position__c positionObj : deptObj.Positions__r)  {
					positionObj.OwnerId = deptObj.OwnerId;
					listPositionToUpdate.add(positionObj);
				}
			}						 	
		}
		if(listPositionToUpdate != NULL && listPositionToUpdate.size() > 0) {
			try {
				database.update(listPositionToUpdate, false);
			}
			catch(Exception e) {
				system.debug('Exception caught while updating records-----------'+e);
			}
		}
	}
}