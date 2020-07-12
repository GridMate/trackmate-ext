global class TrackMateSessionHandler  implements Callable{
    global Object call(String action, Map<String, Object> args) {
        if(action=='setSessionDetails'){
            SObject ie = (SObject)args.get('interactionEvent');
            String sessionId = Auth.SessionManagement.getCurrentSession().get('SessionId');       
            
            AuthSession currentSession = [Select Id, ParentId, LoginHistoryId 
                                          From AuthSession
                                          Where ID =: sessionId];        
            
            String realSessionId = currentSession.Id;
            ie.put('tmpkg__Impersonated_Session__c',false);
            
            if(currentSession.LoginHistoryId == NULL && 
               currentSession.ParentId != NULL){
                   ie.put('tmpkg__Impersonated_Session__c',true); 
                   realSessionId = currentSession.ParentId;
               }
            
            AuthSession realSession = [Select Id, ParentId, LoginHistoryId, UsersId
                                       From AuthSession
                                       Where ID =: realSessionId];
            
            
            if((boolean)ie.get('tmpkg__Impersonated_Session__c')){
                ie.put('tmpkg__Impersonated_ById__c', realSession.UsersId);
            }
            
            LoginHistory logHis = [Select Id, LoginTime, 
                                   SourceIp, 
                                   LoginUrl,                                   
                                   Platform, 
                                   Application, 
                                   Browser,
                                   LoginGeoId
                                   From LoginHistory 
                                   Where Id =: realSession.LoginHistoryId];
            
            ie.put('tmpkg__Login_Time__c', logHis.LoginTime);
            ie.put('tmpkg__Source_IP__c', logHis.SourceIp);
            ie.put('tmpkg__Login_Url__c', logHis.LoginUrl);
            ie.put('tmpkg__Platform__c', logHis.Platform);
            ie.put('tmpkg__Application__c', logHis.Application);
            ie.put('tmpkg__Browser__c', logHis.Browser);
            
            LoginGeo loginGeo = [Select Id, 
                                 Latitude, 
                                 Longitude, 
                                 City, 
                                 Subdivision, 
                                 PostalCode, 
                                 CountryIso
                                 From LoginGeo 
                                 Where Id =: logHis.LoginGeoId];
            
            ie.put('tmpkg__Latitude__c', loginGeo.Latitude);
            ie.put('tmpkg__Longitude__c', loginGeo.Longitude);
            ie.put('tmpkg__City__c', loginGeo.City);
            ie.put('tmpkg__PostalCode__c', loginGeo.PostalCode);
            ie.put('tmpkg__Subdivision__c', loginGeo.Subdivision);
            ie.put('tmpkg__Country_ISO__c', loginGeo.CountryIso);        
            return true;            
        }
        else {
            throw new ExtensionMalformedCallException('Action not implemented');
        }
    }
    
    global class ExtensionMalformedCallException extends Exception {}
}