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


    public static void actionsRelated(Id accountId) {
        try {
            // Create a new case for the account with high risk
            Case newCase = new Case();
            newCase.AccountId = accountId;
            newCase.Subject = 'Case created from Account with high risk';
            newCase.Description = 'Case created from Account with high risk';
            newCase.OwnerId = giveMeRandomUserId();

            insert newCase;

            // Publish platform event
            Global_Platform_Event__e platformEvent = new Global_Platform_Event__e();
            platformEvent.Event_Type__c = 'Account risk high';
            platformEvent.Address__c = 'Case #' + newCase.Id + ' created from Account with high risk';

            Database.SaveResult sr = EventBus.publish(platformEvent);

            if (sr.isSuccess()) {
                System.debug('Platform event published successfully.');
            } else {
                System.debug('Failed to publish platform event. Error: ' + sr.getErrors()[0].getMessage());
            }
        } catch (DmlException dmlEx) {
            System.debug('DML Exception: ' + dmlEx.getMessage());

        } catch (Exception e) {
            System.debug('Unexpected Exception: ' + e.getMessage());

        }
    }

    public static Id giveMeRandomUserId() {
        try {
            List<User> users = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND ProfileId = :UserInfo.getProfileId()];
            return users.isEmpty() ? UserInfo.getUserId() : users[0].Id;
        } catch (Exception e) {
            System.debug('Error fetching random UserId: ' + e.getMessage());
            return UserInfo.getUserId();
        }
    }
}