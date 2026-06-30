public with sharing class RCA_DocGenUtilities {
    @AuraEnabled
    public static String createDocName(Id quoteId) {
        String returnString;
        // Query Quote fields
        Quote q = [SELECT Id, CreatedDate, QuoteNumber, Status FROM Quote WHERE Id = :quoteId];
        // Count content documents
        Integer numberOfFiles = [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :quoteId];
        // Build dynamic title
        returnString = 'Quote ' +
            q.QuoteNumber +
            ' - ' + q.Status +
            ' v' + (numberOfFiles + 1);
        return returnString;
    }
}