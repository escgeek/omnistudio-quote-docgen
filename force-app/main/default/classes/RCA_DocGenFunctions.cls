/*
===============================================================================
 RCA_ DocGen Module – Function Dispatcher
===============================================================================

Class Responsibilities
----------------------
This class acts as the callable façade between OmniStudio/DocGen and the
DocGen helper engine. It exposes a simple, action‑based API that DocGen,
Integration Procedures, and OmniScripts can invoke using the Salesforce
Callable interface.

Referenced Components
---------------------
• RCA_DocGenFunctions
  Main Class Omnistudio uses to execute the appropriate helper
  methods and returns data in a Data Mapper compatible format.

• RCA_DocGenHelper
  Core processing engine that fetches, normalizes, and formats
  Quote Line Item data for Data Mapper consumption.

• RCA_DocGenLineModel
  A lightweight normalized data model representing a single Quote Line Item
  used throughout all transformations.

• RCA_DocGenFunctionsTest
  Comprehensive test suite validating call dispatch, SOQL fetching,
  and formatting logic.

Behavior Summary
----------------
Supported actions (via Callable.call):
• replaceBR            – Normalizes <br> tags into newline characters
• summarizeQuoteLines  – Fetches QLIs by Id and returns normalized line maps
                         with Product Name, List Price, Discount, Sales Price,
                         Quantity, and Sales Total.
• formatCurrency       – Formats a numeric amount using the supplied currency code.

===============================================================================
*/
global class RCA_DocGenFunctions implements Callable {

    public Object call(String action, Map<String, Object> args) {
        Map<String, Object> input   = (Map<String, Object>) args.get('input');
        Map<String, Object> output  = (Map<String, Object>) args.get('output');

        List<Object> arguments = (List<Object>) input.get('arguments');

        if (action == 'replaceBR') {
            output.put('result', RCA_DocGenHelper.replaceBR(arguments));
        }
        else if (action == 'summarizeQuoteLines') {
            output.put('result', RCA_DocGenHelper.summarizeQuoteLines(arguments));
        }
        else if (action == 'formatCurrency') {
            output.put('result', RCA_DocGenHelper.formatCurrency(arguments));
        }

        return true;
    }
}