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
trigger ValidateRiskOnAccount on Account (before update, after insert) {
    new MainTriggerOnAccount().run();
}