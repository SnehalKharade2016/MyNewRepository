public with sharing class UserTriggerHandler { 
    public List<Messaging.SingleEmailMessage> lstMail;
    String strDuration;
    
    public void resetCounterValue(List<User> listNewUser , Map<Id , User> mapOldUser) {
        for(User userObj : listNewUser) {
            if(userObj.LastLoginDate != mapOldUser.get(userObj.Id).LastLoginDate) {
                userObj.Counter__c = 0;
                system.debug('Counter value has been updated sucessfully-----'+ userObj.Counter__c);
            }
        } 
    }
        
   public void sendAlertsToUser(List<User> listUsers, Map<Id,User> oldMapUsers) {
        system.debug('Inside alert -----------');
        Organization orgDetail = [Select o.Name, o.Id From Organization o limit 1];
        lstMail = new List<Messaging.SingleEmailMessage>();
        AutoFreeze_User_Configuration__c autoFreezeUserSetting = AutoFreeze_User_Configuration__c.getOrgDefaults();
        
        if(autoFreezeUserSetting != NULL && (autoFreezeUserSetting.User_not_Logged_in_Since_Last__c != NULL || autoFreezeUserSetting.User_not_Logged_in_Since_Last__c.length() != 0)) {
            String strDWM = autoFreezeUserSetting.User_not_Logged_in_Since_Last__c.substring(autoFreezeUserSetting.User_not_Logged_in_Since_Last__c.length()-1 , autoFreezeUserSetting.User_not_Logged_in_Since_Last__c.length());
            if(!(strDWM.equalsIgnoreCase('d')) && !(strDWM.equalsIgnoreCase('w')) && !(strDWM.equalsIgnoreCase('m'))) {
                strDuration = '1 month';
            }
            else if(strDWM.equalsIgnoreCase('d')) {
                strDuration = autoFreezeUserSetting.User_not_Logged_in_Since_Last__c.removeEnd('d') + 'day / days';
            }
            else if(strDWM.equalsIgnoreCase('w')) {
                strDuration = autoFreezeUserSetting.User_not_Logged_in_Since_Last__c.removeEnd('w') + 'week / weeks';
            }
            else if(strDWM.equalsIgnoreCase('m')) {
                strDuration = autoFreezeUserSetting.User_not_Logged_in_Since_Last__c.removeEnd('m') + 'month / months';
            }
        }
        Set<Id> setUserIds = new Set<Id>();
        List<UserLogin> listUserLoginToUpdate = new List<UserLogin>();
        Set<Id> setFrozenIds = new Set<Id>();
        for(User userObj : listUsers) {
            setUserIds.add(userObj.Id); 
        }
        //List<UserLogin> listUserLogin = new List<UserLogin>([select Id, UserId, IsFrozen from UserLogin where UserId IN : setUserIds]);
        Map<id,UserLogin> MapUsrLogin = new Map<id,UserLogin>();
        for(UserLogin userLoginObj : [select Id, UserId, IsFrozen from UserLogin where UserId IN : setUserIds]) {
            MapUsrLogin.put(userLoginObj.UserId , userLoginObj);
        }
        
        for(User userObj : listUsers) {
            if(userObj.Counter__c != oldMapUsers.get(userObj.Id).Counter__c) {
                if(userObj.Counter__c == 1) {
                    alertUser(userObj , Label.ReminderEmailSubject , orgDetail);
                }
                else if(userObj.Counter__c == 2) {
                    alertUser(userObj , Label.ReminderEmailSubject , orgDetail);
                }
                else if(userObj.Counter__c == 3) {
                    alertUser(userObj , Label.ReminderEmailSubject , orgDetail);
                }
                else if(userObj.Counter__c == 4) {
                    if(MapUsrLogin.containsKey(userObj.Id)) {
                        if(!MapUsrLogin.get(userObj.Id).IsFrozen) {
                            MapUsrLogin.get(userObj.Id).IsFrozen = true;
                            listUserLoginToUpdate.add(MapUsrLogin.get(userObj.Id));
                            setFrozenIds.add(userObj.Id);
                        }
                    }
                    alertAboutAccountFrozen(userObj , Label.UserNotificationEmailSubject , orgDetail);
                }
            }
        }
        
        try {
            update listUserLoginToUpdate;
            system.debug('MailingListCheck--------'+lstMail);
            sendFrozenAccountListToAdmin(setFrozenIds , label.AdminNotificationEmaiSubject , orgDetail);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMail);
        }
        catch(Exception e) {
            System.debug('Exception Caught while sending mail to Users : '+e.getMessage());
        }
    }
    
    public void alertUser(User userObj , String strSubject , Organization orgDetail) {
        List<String> toAddress=new List<String>();
        List<String> ccAddress=new  List<String>();      
        toAddress.add(userObj.Email); 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //ccAddress.addAll(lstMailIds); 
        mail.setToAddresses(toAddress); 
        mail.setCcAddresses(ccAddress); 
        String strUserName = (userObj.FirstName != NULL ? userObj.FirstName : '');
        strUserName += (userObj.LastName != NULL ? userObj.LastName : '');
        
        String introduction = '<html><head></head><body>Hi '+ strUserName +', <br/><br/>This is to inform you that your salesforce account will be freezed as you have not logged in to SFDC from last '+ strDuration +'. Please login once to your salesforce account in order to avoid account deactivation.';
        String strBody = '<br/><br/>Thanks,<br/>';
        if(orgDetail.Name != NULL) {
            strBody += orgDetail.Name +'.</body></html>';
        }
        
        mail.setHtmlBody(introduction + strBody);
        mail.setSubject(strSubject);
        lstMail.add(mail);
    }
    
    public void alertAboutAccountFrozen(User userObj , String strSubject , Organization orgDetail) {
        List<String> toAddress=new List<String>();
        List<String> ccAddress=new  List<String>();      
        toAddress.add(userObj.Email); 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddress); 
        mail.setCcAddresses(ccAddress); 
        String strUserName = (userObj.FirstName != NULL ? userObj.FirstName : '');
        strUserName += (userObj.LastName != NULL ? (' ' + userObj.LastName) : '');
        String introduction = '<html><head></head><body>Hi '+ strUserName +', <br/><br/>This is to inform you that account has been frozen as u have not logged in to SFDC since from last '+ strDuration;
        String strBody = '.<br/><br/>Thank You,<br/>';
        if(orgDetail.Name != NULL) {
            strBody += orgDetail.Name +'.</body></html>';
        }
        mail.setHtmlBody(introduction + strBody);
        mail.setSubject(strSubject);
        lstMail.add(mail);
    }
    
    public void sendFrozenAccountListToAdmin(Set<Id> setFrozenUsers, String strSubject , Organization orgDetail) {
        system.debug('setFrozenUsers-------------------------'+setFrozenUsers);
        if(setFrozenUsers != NULL && setFrozenUsers.size() > 0) {
            List<String> toAddress=new List<String>();
            List<String> ccAddress=new  List<String>();
            String strTableHeader = '';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Profile adminProfile = [Select p.Name, p.Id From Profile p where p.Name = 'System Administrator' limit 1];
            List<User> listAdminUsers = new List<User>([Select u.ProfileId, u.Name, u.Id, u.Email From User u where u.ProfileId =: adminProfile.Id]);
            List<User> listFrozenuserDetails = new List<User>([Select u.Profile.Name, u.ProfileId, u.Name, u.Manager.Name, u.ManagerId, u.Id, u.Email, u.CompanyName, u.Alias From User u where Id IN : setFrozenUsers]);
            If(listFrozenuserDetails != NULL && listFrozenuserDetails.size() > 0) {
                strTableHeader = '<table style = "border: 1px solid black;" cellspacing="0"><tr style = "font-weight:bold; border: 1px solid black;" bgcolor = "#BBE7FF"><th style = "border: 1px solid black;" align = "center"> User Name </th><th style = "border: 1px solid black;" align = "center"> Company </th><th style = "border: 1px solid black;" align = "center"> Email Address </th><th style = "border: 1px solid black;" align = "center"> Manager </th><th style = "border: 1px solid black;" align = "center"> Profile </th></tr>';
                for(User userObj : listFrozenuserDetails) {
                    strTableHeader += '<tr style = "border: 1px solid black;"><td style = "border: 1px solid black;" align = "center"> '+ userObj.Name + '</td> ';
                    strTableHeader += (userObj.CompanyName != NULL ? '<td style = "border: 1px solid black;" align = "center"> '+ userObj.CompanyName + '</td> ' : '<td style = "border: 1px solid black;" align = "center"> - </td> ');
                    strTableHeader += (userObj.Email != NULL ? '<td style = "border: 1px solid black;" align = "center"> '+ userObj.Email + '</td> ' : '<td style = "border: 1px solid black;" align = "center"> - </td> ');
                    strTableHeader += (userObj.ManagerId != NULL ? '<td style = "border: 1px solid black;" align = "center"> '+ userObj.Manager.Name + '</td> ' : '<td style = "border: 1px solid black;" align = "center"> - </td> ');
                    strTableHeader += (userObj.ProfileId != NULL ? '<td style = "border: 1px solid black;" align = "center"> '+ userObj.Profile.Name + '</td> ' : '<td style = "border: 1px solid black;" align = "center"> - </td> </tr>');
                }
                strTableHeader += '</table>';
            }
            
            for(User adminUserObj : listAdminUsers) {
                toAddress.add(adminUserObj.Email); 
            }
            ccAddress.add('snehal.kharade@eternussolutions.com'); 
            mail.setToAddresses(toAddress); 
            mail.setCcAddresses(ccAddress);
            String introduction = '<html><head></head><body> Greetings , <br/><br/> Please find below user details which have been frozen - <br/> <br/>';
            introduction += strTableHeader;
            String strBody = '<br/><br/>Thank You,<br/>';
            if(orgDetail.Name != NULL) {
                strBody += orgDetail.Name +'.</body></html>';
            }
            mail.setHtmlBody(introduction + strBody);
            mail.setSubject(strSubject);
            lstMail.add(mail);
        }
    }
}