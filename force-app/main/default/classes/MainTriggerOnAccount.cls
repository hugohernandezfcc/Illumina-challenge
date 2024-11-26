/**
 * @description       : 
 * @author            : hugo.hernandez
 * @group             : 
 * @last modified on  : 11-26-2024
 * @last modified by  : hugo.hernandez
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   11-26-2024   hugo.hernandez   Initial Version
**/
public without sharing class MainTriggerOnAccount extends TriggerHandler{

    public Account accountNew {get; set;}
    public Account accountOld {get; set;}
    public MainTriggerOnAccount() {
        System.debug('Starting controller MainTriggerOnAccount');

        switch on Trigger.operationType {
            when BEFORE_UPDATE {
                if(Trigger.new.size() <= 1 ){
                    accountNew = (Account) Trigger.new[0];
                    accountOld = (Account) Trigger.old[0];
                }
            }
            when after_INSERT {
                if(Trigger.new.size() <= 1 )
                    accountNew = (Account) Trigger.new[0];
            }
        }

    }

    public override void beforeUpdate() {

        if(accountNew != null && accountOld != null){
            if(accountNew.Risk__c == 'High' && accountOld.Risk__c != 'High'){
                if (!accountNew.Use_Flow__c) {
                    System.debug('Account with high risk UPDATE');
                    actionsRelated(accountNew.Id);
                }

            }
        }
    }

    public override void afterInsert() {
        if(accountNew != null){
            if(accountNew.Risk__c == 'High'){
                if (!accountNew.Use_Flow__c) {
                    System.debug('Account with high risk INSERT');
                    actionsRelated(accountNew.Id);
                }

            }
        }
    }


    public static void actionsRelated(Id AccountId){
        Case newCase = new Case();
        newCase.AccountId = AccountId;
        newCase.Subject = 'Case created from Account with high risk';
        newCase.Description = 'Case created from Account with high risk';
        newCase.OwnerId = giveMeRandomUserId();
        insert newCase;        
    }

    public static Id giveMeRandomUserId(){
        
        List<User> users = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND ProfileId =: UserInfo.getProfileId()];
        if(users.isEmpty())
            return UserInfo.getUserId();
        else
            return users[0].Id;
    }
}