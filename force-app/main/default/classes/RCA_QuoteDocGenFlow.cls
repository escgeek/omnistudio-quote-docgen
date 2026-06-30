public without sharing class RCA_QuoteDocGenFlow {
    public static Boolean throwError = false;

    // Simple test wrapper
    // List<RCA_QuoteDocGenFlow.Result> flowResults = RCA_QuoteDocGenFlow.testDocGen('quoteId');
    public static List<Result> testDocGen(Id quoteId){
        Request req = new Request();
        req.quoteId = quoteId;
        req.quoteDocName = 'Test Document';
        return generate(new List<Request>{req});
    }

    // -------------------------------------------------------------
    // Invocable Request Class
    // -------------------------------------------------------------
    public class Request {
        @InvocableVariable(required=true)
        public String quoteId;

        @InvocableVariable(required=true)
        public String quoteDocName;
    }

    // -------------------------------------------------------------
    // Invocable Result Class
    // -------------------------------------------------------------
    public class Result {

        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public String dgpId;

        @InvocableVariable
        public String errorMessage;

        public Result(Boolean success, String dgpId, String errorMessage) {
            this.success = success;
            this.dgpId = dgpId;
            this.errorMessage = errorMessage;
        }
    }

    // -------------------------------------------------------------
    // Invocable Method – entry point from Flow
    // -------------------------------------------------------------
    @InvocableMethod(
        label='Generate Customer Quote Document'
        description='Triggers DocGen for CustomerQuoteDoc and returns success, DGP Id, and error.'
    )
    public static List<Result> generate(List<Request> requests) {

        List<Result> results = new List<Result>();

        for (Request req : requests) {
            Boolean ok = false;
            String dgpId = null;
            String err = null;

            try {
                Map<String, Object> outcome = runInternal(req.quoteId, req.quoteDocName);
                ok = (Boolean) outcome.get('success');
                dgpId = (String) outcome.get('dgpId');
                err = (String) outcome.get('error');
            } catch (Exception ex) {
                ok = false;
                err = ex.getMessage();
            }

            results.add(new Result(ok, dgpId, err));
        }

        return results;
    }

    // -------------------------------------------------------------
    // Core Logic (returns a Map instead of just Boolean)
    // -------------------------------------------------------------
    private static Map<String, Object> runInternal(String quoteId, String quoteDocName) {

        Map<String, Object> response = new Map<String, Object>{
            'success' => false,
            'dgpId' => null,
            'error' => null
        };

        // 1. Lookup DocumentTemplate by Name (SAFE LIST QUERY)
        List<DocumentTemplate> tmplList = [
            SELECT Id, Name
            FROM DocumentTemplate
            WHERE Name = 'CustomerQuoteDoc'
            LIMIT 1
        ];

        if (tmplList.isEmpty()) {
            response.put('error', 'DocumentTemplate: CustomerQuoteDoc not found.');
            return response;
        }

        DocumentTemplate tmpl = tmplList[0];

        // 2. Lookup related ContentDocument (SAFE LIST QUERY)
        List<DocumentTemplateContentDoc> docLinks = [
            SELECT ContentDocumentId
            FROM DocumentTemplateContentDoc
            WHERE DocumentTemplateId = :tmpl.Id
            LIMIT 1
        ];

        if (docLinks.isEmpty()) {
            response.put('error', 'DocumentTemplateContentDoc not found for template.');
            return response;
        }

        DocumentTemplateContentDoc docLink = docLinks[0];

        // 3. Latest ContentVersion (SAFE LIST QUERY)
        List<ContentVersion> versions = [
            SELECT Id, ContentDocumentId, VersionNumber
            FROM ContentVersion
            WHERE ContentDocumentId = :docLink.ContentDocumentId
            ORDER BY VersionNumber DESC
            LIMIT 1
        ];

        ContentVersion ver = versions[0];

        // 4. Build RequestText JSON for DocGen API
        Map<String, Object> requestData = new Map<String, Object>{
            'keepIntermediate' => false,
            'title' => quoteDocName,
            'templateContentVersionId' => ver.Id
        };

        // 5. Build & insert DocumentGenerationProcess
        DocumentGenerationProcess dgp = new DocumentGenerationProcess();
        dgp.ReferenceObject = quoteId;
        dgp.DocumentInputType = 'DocumentTemplate';
        dgp.DocGenApiVersionType = (!throwError) ? 'Advanced' : 'Throw Error';
        dgp.Type = 'GenerateAndConvert';

        dgp.DataRaptorInput = '{"Id":"' + quoteId + '"}';
        dgp.DocumentTemplateId = tmpl.Id;
        dgp.RequestText = JSON.serialize(requestData);

        insert dgp;

        // SUCCESS
        response.put('success', true);
        response.put('dgpId', dgp.Id);
        return response;
    }
}