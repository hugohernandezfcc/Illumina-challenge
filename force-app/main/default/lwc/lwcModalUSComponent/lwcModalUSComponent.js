/**
 * @description       : 
 * @author            : hugo.hernandez
 * @group             : 
 * @last modified on  : 11-15-2024
 * @last modified by  : hugo.hernandez
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   11-15-2024   hugo.hernandez   Initial Version
**/
import { api, wire } from 'lwc';
import LightningModal from 'lightning/modal';

export default class LwcModalUSComponent extends LightningModal {
    @api address = {};
    placeName = '';
    latitude = '';
    longitude = '';
    state = '';

    connectedCallback() {
        this.placeName = this.address.places[0]['place name'];
        this.latitude = this.address.places[0].latitude;
        this.longitude = this.address.places[0].longitude;
        this.state = this.address.places[0].state;
        
    }
    handleOkay() {
        this.close('okay');
    }
}