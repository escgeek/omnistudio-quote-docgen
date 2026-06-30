/*
Test Script:
// Anonymous Apex test for RCA_DocGenCurrency
// Using the pattern: (Double) <number>

System.debug('==== TEST: USD ====');
String usd = RCA_DocGenCurrency.formatCurrency((Double) 1234.56, 'USD');
System.debug('USD: ' + usd);
// Expected: $1,234.56

System.debug('==== TEST: EUR ====');
String eur = RCA_DocGenCurrency.formatCurrency((Double) 1234.56, 'EUR');
System.debug('EUR: ' + eur);
// Expected: €1.234,56

System.debug('==== TEST: JPY ====');
String jpy = RCA_DocGenCurrency.formatCurrency((Double) 6500, 'JPY');
System.debug('JPY: ' + jpy);
// Expected: ¥6,500

// Summary
System.debug('==== SUMMARY ====');
System.debug('USD => ' + usd);
System.debug('EUR => ' + eur);
System.debug('JPY => ' + jpy);
 */
public class RCA_DocGenCurrency {
    /**
     * Formats a numeric amount based on a currency code.
     * Currently supports: USD, EUR.
     *
     * @param amount       The numeric value to format.
     * @param currencyCode The 3-letter ISO currency code (e.g., 'USD', 'EUR').
     * @return A formatted string version of the number.
     */
    public static String formatCurrency(Double amount, String currencyCode) {
        // Nulls check
        amount = amount ?? 0.0;
        currencyCode = (currencyCode != null) ? currencyCode.trim().toUpperCase() : 'USD';

        RCA_Currency_Format__mdt cfg = getCurrencyConfig(currencyCode);

        if (cfg == null) {
            return '$' + (String) amount.format(); // Fallback to USD-style
        }

        Integer decimals = (cfg.Decimal_Places__c == '0') ? 0 : 2;

        // Convert Double → Decimal so we can use setScale
        Decimal decAmount = (amount == null) ? 0 : Decimal.valueOf(amount);

        // Format using fixed decimal places, but WITHOUT separators added by Salesforce
        String raw = String.valueOf(decAmount.setScale(decimals));

        // Split integer and decimal components
        List<String> parts = raw.split('\\.');
        String intPart = parts[0];
        String decPart = (parts.size() > 1) ? parts[1] : '';

        // Convert picklist strings → characters
        String thousandSep = mapSeparator(cfg.Thousands_Separator__c);
        String decimalSep = mapSeparator(cfg.Decimal_Separator__c);
        String symbol = cfg.Symbol__c;

        // Apply thousands separator
        String formattedInt = applyThousands(intPart, thousandSep);

        // Reassemble number with metadata-based decimal separator
        String formattedNumber = (decimals > 0) ? formattedInt + decimalSep + decPart : formattedInt;

        // Apply symbol position
        String finalReturnString = (cfg.Symbol_Position__c == 'Suffix') ? formattedNumber + symbol : symbol + formattedNumber;

        return finalReturnString;
    }

    /* ---------------------------------------------------------
       Metadata Lookup
    --------------------------------------------------------- */
    private static RCA_Currency_Format__mdt getCurrencyConfig(String code) {
        return RCA_Currency_Format__mdt.getInstance(code);
    }

    /* ---------------------------------------------------------
       Convert picklist values → actual characters
       Thousands_Separator__c options: Comma, Dot, Space
       Decimal_Separator__c options: Comma, Dot
    --------------------------------------------------------- */
    public static String mapSeparator(String picklistValue) {
        switch on picklistValue {
            when 'Comma'  { return ','; }
            when 'Dot'    { return '.'; }
            when 'Space'  { return ' '; }
            when else     { return ''; }
        }
    }

    /* ---------------------------------------------------------
       Thousands separator logic
    --------------------------------------------------------- */
    public static String applyThousands(String inputNumber, String sep) {
        if (sep == null || sep == '') return inputNumber;

        String result = '';
        Integer count = 0;

        for (Integer i = inputNumber.length() - 1; i >= 0; i--) {
            result = inputNumber.substring(i, i + 1) + result;
            count++;

            if (count == 3 && i > 0) {
                result = sep + result;
                count = 0;
            }
        }
        return result;
    }
}