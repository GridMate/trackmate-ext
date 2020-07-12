@isTest
global class TrackMateSessionHandlerTest {
    static SObject getNewSobject(String typeName) {
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(typeName);
        Sobject sobj = objType.newSobject();        
        return sobj;
    }  
    
    static testMethod void testSetSessionDetails(){       
        SObject interaction = getNewSobject('tmpkg__User_Interaction_Event__e');        
        interaction.put('tmpkg__Timestamp__c', System.now());
        interaction.put('tmpkg__Type__c', 'Navigate To');
        interaction.put('tmpkg__Path__c', '/lightning/o/User');
        interaction.put('tmpkg__Impersonated_Session__c', false);
        
        Callable handler =  (Callable) Type.forName('TrackMateSessionHandler').newInstance();
        Boolean result = (Boolean) handler.call('setSessionDetails', new Map<String, Object> { 
            'interactionEvent' => interaction                
		});     
    }
}