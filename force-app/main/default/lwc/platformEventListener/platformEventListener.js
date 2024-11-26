/**
 * @description       : 
 * @author            : hugo.hernandez
 * @group             : 
 * @last modified on  : 11-26-2024
 * @last modified by  : hugo.hernandez
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   11-15-2024   hugo.hernandez   Initial Version
**/
import { LightningElement } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag } from 'lightning/empApi';

export default class PlatformEventListener extends LightningElement {
    // Platform Event channel to subscribe to
    channelName = '/event/Global_Platform_Event__e';
    subscription = {};
    
    messageReceived = false; 
    envetTypeField = ''; 
    eventAddressfield = ''; 
    typeEventFrontEnd = '';

    connectedCallback() {
        this.subscribeToEvent();
    }


    subscribeToEvent() {
        const messageCallback = (response) => {
            console.log('New message received: ', JSON.stringify(response));

            // Extract field values from the event
            const eventData = response.data.payload;
            this.envetTypeField = eventData.Event_Type__c;
            this.eventAddressfield = eventData.Address__c;
            this.typeEventFrontEnd = (this.envetTypeField === 'Account risk high') ? true : false; 
            

            this.messageReceived = true;
        };


        subscribe(this.channelName, -1, messageCallback).then((response) => {
            console.log('Subscribed to platform event channel:', response.channel);
            this.subscription = response;
        });


        onError((error) => {
            console.error('Error while subscribing to platform event: ', error);
        });
    }


    unsubscribeFromEvent() {
        unsubscribe(this.subscription, response => {
            console.log('Unsubscribed from channel:', response);
        });
    }


    enableDebug() {
        setDebugFlag(true);
    }
}