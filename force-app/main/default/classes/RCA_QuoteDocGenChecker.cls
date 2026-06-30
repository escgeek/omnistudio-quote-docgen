public with sharing class RCA_QuoteDocGenChecker {

    @AuraEnabled(cacheable=false)
    public static String getProcessStatus(Id dgpId) {
        try {
            DocumentGenerationProcess dgp = [
                SELECT Id, Status
                FROM DocumentGenerationProcess
                WHERE Id = :dgpId
                LIMIT 1
            ];
            // Return the Status as a string ("InProgress", "Success", "Failure")
            return dgp.Status;
        } catch (Exception e) {
            // wrap all other unexpected failures cleanly
            throw new RCA_QuoteDocGenCheckerException('Error retrieving DocumentGenerationProcess: ' + e.getMessage());
        }
    }

    // Custom Exception class
    public class RCA_QuoteDocGenCheckerException extends Exception {}
}