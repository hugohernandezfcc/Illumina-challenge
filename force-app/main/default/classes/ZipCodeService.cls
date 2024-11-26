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
public class ZipCodeService {

    @AuraEnabled(cacheable=true)
    public static String getLocationData(String zipCode, String country) {

        if (String.isBlank(zipCode)) 
            return 'Error: zipCode parameter is required.';
        
        
        if (String.isBlank(country)) 
            return 'Error: country parameter is required.';
        
        
        if (!Pattern.matches('^[0-9]+$', zipCode)) 
            return 'Error: zipCode should contain only digits.';

        
        if (country.length() != 2) 
            return 'Error: country should be a 2-letter ISO code.';
        

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        try {
            // Set request parameters
            req.setEndpoint('callout:zippopotam/' + country + '/' + zipCode);
            req.setMethod('GET');

            // Send request and get response
            HttpResponse res = http.send(req);
            Integer statusCode = res.getStatusCode();

            // Handle responses
            if (statusCode == 200) {
                return res.getBody();
            } else if (statusCode == 404) {
                return 'Error: Zip code not found';
            } else if (statusCode == 500) {
                return 'Error: Internal server error';
            } else {
                return 'Error: ' + res.getStatus() + ' - ' + res.getBody();
            }

        } catch (CalloutException e) {
            // Log the specific error for callout issues
            System.debug('Callout error: ' + e.getMessage());
            return 'Error: Failed to send the request. ' + e.getMessage();
        } catch (Exception e) {
            // Log and return any other unexpected errors
            System.debug('Unexpected error: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }

    @AuraEnabled
    public static void createAddress(String accountId, String placename, String state, String latitude, String longitude) {
        // Validate inbound parameters
        if (String.isBlank(accountId)) {
            throw new AuraHandledException('Error: accountId parameter is required.');
        }
        
        if (String.isBlank(placename)) {
            throw new AuraHandledException('Error: placename parameter is required.');
        }
        
        if (String.isBlank(state)) {
            throw new AuraHandledException('Error: state parameter is required.');
        }
    
        if (String.isBlank(latitude) || !isValidCoordinate(latitude)) {
            throw new AuraHandledException('Error: A valid latitude is required.');
        }
    
        if (String.isBlank(longitude) || !isValidCoordinate(longitude)) {
            throw new AuraHandledException('Error: A valid longitude is required.');
        }
    
        try {
            // Create a new Address record
            Address__c address = new Address__c();
            address.Account__c = Id.valueOf(accountId);
            address.Place_Name__c = placename;
            address.latitude__c = latitude;
            address.longitude__c = longitude;
            address.state__c = state;
    
            insert address;
    
            // Publish a platform event
            Global_Platform_Event__e platformEvent = new Global_Platform_Event__e();
            platformEvent.Event_Type__c = 'Non-US territory found';
            platformEvent.Address__c = placename + ', ' + state + ', ' + latitude + '-' + longitude;
    
            Database.SaveResult sr = EventBus.publish(platformEvent);
    
            if (sr.isSuccess()) {
                System.debug('Platform event published successfully.');
            } else {
                System.debug('Failed to publish platform event. Error: ' + sr.getErrors()[0].getMessage());
            }
            
        } catch (DmlException e) {
            // Handle DML errors (inserts)
            System.debug('DML Error: ' + e.getMessage());
            throw new AuraHandledException('Error: Could not create Address record. ' + e.getMessage());
        } catch (Exception e) {
            // Handle unexpected exceptions
            System.debug('Unexpected Error: ' + e.getMessage());
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
    
    // Helper method to validate latitude/longitude as valid decimal coordinates
    public static Boolean isValidCoordinate(String coordinate) {
        try {
            Decimal coord = Decimal.valueOf(coordinate);
            return coord >= -180 && coord <= 180; // Valid range for latitude/longitude
        } catch (Exception e) {
            return false; // Invalid format (not a decimal)
        }
    }
}
