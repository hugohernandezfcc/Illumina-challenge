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

import { LightningElement, api } from 'lwc';
import getLocationData from '@salesforce/apex/ZipCodeService.getLocationData';
import createAddress from '@salesforce/apex/ZipCodeService.createAddress';
import lwcModalUSComponent from 'c/lwcModalUSComponent';
export default class ZipcodeComponent extends LightningElement {
        @api recordId;
        zipCode = '';
        city = '';
        state = '';
        country = '';
        errorMessage = '';
        locationFound = false;
    
        valueCountry = 'Select a zip code';
        optionsCountry = [
            { label: 'España', value: 'es' },
            { label: 'United States', value: 'us' },
            { label: 'Mexico', value: 'mx' }
        ];

        handleChange(event) {
            this.valueCountry = event.detail.value;
        }

        handleZipChange(event) {
            this.zipCode = event.target.value;
        }

        connectedCallback() {
            console.log('recordId: ' + this.recordId);
        }
    

        handleGetLocation() {

            this.city = '';
            this.state = '';
            this.country = '';
            this.errorMessage = '';
            this.locationFound = false;
    

            if (this.zipCode.length !== 5 || isNaN(this.zipCode)) {
                this.errorMessage = 'Please enter a valid 5-digit US zip code.';
                return;
            }
    

            getLocationData({ zipCode: this.zipCode, country: this.valueCountry })
                .then((response) => {
                    let data = JSON.parse(response);
                    console.log('data: ' + JSON.stringify(data));
                    
                    
                    console.log(data["country abbreviation"])
                    if (data["country abbreviation"] != 'US' && data.places.length > 0) {
                        this.city = data.places[0]['place name'];
                        this.state = data.places[0]['state abbreviation'];
                        this.country = data.country;

                        createAddress({
                            accountId: this.recordId,
                            placename: this.city, 
                            state: this.state, 
                            latitude: data.places[0]['latitude'],
                            longitude: data.places[0]['longitude']
                        }).then((response) => {
                            this.locationFound = true;

                        }).catch((error) => {
                            console.log('error: ' + JSON.stringify(error));
                        });

                    }else{

                        const modalShow = lwcModalUSComponent.open({
                            address: data
                        })

                    }
                })
                .catch((error) => {
                    this.errorMessage = 'Error fetching location: ' + error.body.message;
                });
        }
    }