import { LightningElement, api } from 'lwc';
import createDocName from '@salesforce/apex/RCA_DocGenUtilities.createDocName';
/* This is used for Omniscript */
export default class QuoteDocGen extends LightningElement {
    @api recordId;
    @api templateId;

    /* Not Needed
    type = 'docGenerationSample';
    subType = 'CoreSingleDocxLWC'; */
    type = 'docGeneration';
    subType = 'quoteDoc'; // 
    language = 'English';

    dynamicDocTitle = null;
    isReady = false;

    async connectedCallback() {
        if (!this.recordId) {
            return;
        }
        try {
            // Call Apex utility to generate the document name
            this.dynamicDocTitle = await createDocName({
                quoteId: this.recordId
            });
        } catch (error) {
            console.error('Error generating document name:', error);
        } finally {
            this.isReady = true;
        }
    }

    get prefill() {
        return JSON.stringify({
            recordId: this.recordId,
            templateId: this.templateId,
            fontSource: "Rich Text Editor Font",
            attachDocument: "pdf",
            serviceFunction: "generateDocument",
            defaultDocumentName: this.dynamicDocTitle || 'Generating...',
            contentVersionNumber: "1",
            outputFileFormat: "pdf"
        });
    }
}