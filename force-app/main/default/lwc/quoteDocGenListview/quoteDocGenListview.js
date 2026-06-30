import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getData from '@salesforce/apex/RCA_DocGenListView.getData';
import getTotalCount from '@salesforce/apex/RCA_DocGenListView.getTotalCount';

export default class quoteDocGenListview extends NavigationMixin(LightningElement) {
    @api recordId;

    @track data = [];
    @track originalData = [];
    @track sortedBy = 'createdDate';
    @track sortedDirection = 'desc';
    @track error;
    @track totalCount = 0;

    batchSize = 5;

    fieldMap = {
        contentUrl: 'ContentDocument.Title',
        owner: 'ContentDocument.CreatedBy.Name',
        createdDate: 'ContentDocument.CreatedDate'
    };

    columns = [
        {
            label: 'Title',
            fieldName: 'title',
            type: 'button',
            sortable: false,
            typeAttributes: {
                label: { fieldName: 'title' },
                name: 'preview',
                variant: 'base'
            }
        },
        {
            label: 'Owner',
            fieldName: 'owner',
            type: 'text',
            sortable: false
        },
        {
            label: 'Created Date/Time',
            fieldName: 'createdDate',
            type: 'date',
            sortable: false,
            typeAttributes: {
                year: "numeric",
                month: "2-digit",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit",
                second: "2-digit"
            }
        }
    ];

    connectedCallback() {
        this.loadTotalCount();
        this.loadInitialData();

    }

    getBackendSortField() {
        return this.fieldMap[this.sortedBy] || 'ContentDocument.CreatedDate';
    }

    loadInitialData() {
        this.fetchRecords(0);
    }

    loadTotalCount() {
        getTotalCount({ recordId: this.recordId })
            .then(result => {
                this.totalCount = result || 0;
            })
            .catch(error => {
                console.error('Count error:', error);
                this.totalCount = 0;
            });
    }

    fetchRecords(startIndex) {
        getData({
            startIndex,
            batchSize: this.batchSize,
            recordId: this.recordId,
            sortBy: this.getBackendSortField(),
            sortDirection: this.sortedDirection
        })
        .then(result => {
            const mapped = result.map(row => {
                const doc = row.ContentDocument;
                return {
                    id: row.ContentDocumentId,
                    title: doc.Title,
                    owner: doc.CreatedBy?.Name,
                    createdDate: doc.CreatedDate,
                    contentUrl: `/lightning/r/ContentDocument/${row.ContentDocumentId}/view`
                };
            });

            if (startIndex === 0) {
                this.data = mapped;
                this.originalData = mapped;
            } else {
                this.data = [...this.data, ...mapped];
                this.originalData = [...this.originalData, ...mapped];
            }

            if (mapped.length < this.batchSize) {
                this.hideLoadMoreButton();
            }

            this.error = undefined;
        })
        .catch(error => {
            console.error('Error loading data:', error);
            this.error = error;
            this.data = [];
        });
    }

    loadMoreData() {
        this.fetchRecords(this.data.length);
    }

    hideLoadMoreButton() {
        const btn = this.template.querySelector('.load-more-container');
        if (btn) btn.classList.add('slds-hide');
    }

    handleSort(event) {
        const { fieldName, sortDirection } = event.detail;
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        const totalLoaded = this.data.length;

        getData({
            startIndex: 0,
            batchSize: totalLoaded,
            recordId: this.recordId,
            sortBy: this.getBackendSortField(),
            sortDirection: this.sortedDirection
        })
        .then(result => {
            const mapped = result.map(row => {
                const doc = row.ContentDocument;
                return {
                    id: row.ContentDocumentId,
                    title: doc.Title,
                    owner: doc.CreatedBy?.Name,
                    createdDate: doc.CreatedDate,
                    contentUrl: `/lightning/r/ContentDocument/${row.ContentDocumentId}/view`
                };
            });

            this.data = mapped;
            this.originalData = mapped;

            if (mapped.length < totalLoaded) {
                this.hideLoadMoreButton();
            } else {
                const btn = this.template.querySelector('.load-more-container');
                if (btn) btn.classList.remove('slds-hide');
            }

            this.error = undefined;
        })
        .catch(error => {
            console.error('Sort fetch error:', error);
            this.error = error;
        });
    }

    handleRowAction(event) {
        const docId = event.detail.row.id;

        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: docId
            }
        });
    }

    handleRefresh() {
        this.data = [];
        this.originalData = [];
        this.loadTotalCount();
        this.loadInitialData();

        // Unhide "Show More" button if previously hidden
        const btn = this.template.querySelector('.load-more-container');
        if (btn) btn.classList.remove('slds-hide');
    }

    get totalRecords() {
        return this.data.length;
    }

    get isLoadMoreHidden() {
        return this.template?.querySelector('.load-more-container')?.classList.contains('slds-hide');
    }

    get cardTitle() {
        return `Quote Documents (${this.totalCount})`;
    }
}