import { LightningElement, api } from 'lwc';
import getProcessStatus from '@salesforce/apex/RCA_QuoteDocGenChecker.getProcessStatus';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class quoteDocGenChecker extends LightningElement {
    @api recordId;
    @api numberOfRetries = 15;
    @api secondsBetweenRetries = 2;

    loading = true;
    hasError = false;
    errorMessage = null;

    connectedCallback() {
        this.pollStatus();
    }

    async pollStatus() {
        let attempts = 0;

        while (attempts < this.numberOfRetries) {
            try {
                const status = await getProcessStatus({ dgpId: this.recordId });

                console.log('DGP Status: ' + status);

                if (status === 'Success') {
                    this.loading = false;
                    this.navigateNext();
                    return;
                }

                if (status === 'Failure') {
                    this.loading = false;
                    this.hasError = true;
                    this.errorMessage = 'Document generation failed.';
                    return;
                }
            } catch (err) {
                console.error(err);
                this.loading = false;
                this.hasError = true;
                this.errorMessage = err?.body?.message || err?.message || 'An unknown error occurred.';
                return;
            }

            attempts++;

            await this.sleep(this.secondsBetweenRetries * 1000);
        }

        // TIMEOUT CASE
        this.loading = false;
        this.hasError = true;
        this.errorMessage = null;
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    handleContinue() {
        this.navigateNext();
    }

    navigateNext() {
        this.dispatchEvent(new FlowNavigationNextEvent());
    }
}