public with sharing class RCA_DocGenListView {

    @AuraEnabled(cacheable=false)
    public static Integer getTotalCount(String recordId) {
        return (Integer) Database.countQuery('SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :recordId');
    }

    @AuraEnabled(cacheable=false)
    public static List<SObject> getData(
        Integer startIndex,
        Integer batchSize,
        String recordId,
        String sortBy,
        String sortDirection
    ) {
        startIndex = (startIndex == null) ? 0 : startIndex;
        batchSize  = (batchSize == null)  ? 10 : batchSize;

        // Defaults
        sortBy = (String.isBlank(sortBy)) ? 'ContentDocument.CreatedDate' : sortBy;
        sortDirection = (String.isBlank(sortDirection)) ? 'DESC' : sortDirection;

        String query =
            'SELECT ' +
                'ContentDocumentId, ' +
                'ContentDocument.Title, ' +
                'ContentDocument.CreatedDate, ' +
                'ContentDocument.CreatedBy.Name ' +
            'FROM ContentDocumentLink ' +
            'WHERE LinkedEntityId = :recordId ' +
            'ORDER BY ' + sortBy + ' ' + sortDirection + ' ' +
            'LIMIT :batchSize OFFSET :startIndex';

        System.debug('RCA_DocGenListView Query: ' + query);

        return Database.query(query);
    }
}