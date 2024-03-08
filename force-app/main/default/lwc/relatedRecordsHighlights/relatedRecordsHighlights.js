import { LightningElement, api, track } from "lwc";
import getHighlightItems from "@salesforce/apex/RelatedRecordsHighlightsController.getHighlightItems";

import { Column } from "./column.js";

export default class relatedRecordsHighlights extends LightningElement {
    @api recordId;
    @api componentId;
    @api maxDisplayRows;
    @api flexipageRegionWidth;

    @track items;

    @track tableColumns = [];
    columnsByItem = new Map();

    @track expandedItemRecords;
    @track expandedItemError;

    @track error;

    currentPage = 1;
    maxPage;

    renderComponent;
    showTable = false;
    showItemSpacer = false;
    displayError = false;

    get showNavigationArrows() {
        return this.maxPage !== 1;
    }

    genericErrorMessageHeader =
        "Oh no! The panel could not be loaded. Please share the message below with your admin.";

    connectedCallback() {
        if (this.recordId) {
            getHighlightItems({
                recordId: this.recordId,
                componentId: this.componentId
            })
                .then((result) => {
                    this.parseData(result);
                })
                .then(() => {
                    this.setCSS();
                })
                .catch((error) => {
                    this.error = error;
                    console.log("Error", error);
                });
        }
    }
    parseData(data) {
        this.items = data;

        if(this.items.length === 0){
            this.renderComponent = false;
            return;
        }
        this.renderComponent = true;
        this.items.forEach((item) => {
            this.setRecordUrl(item);
            this.constructTableColumn(item);
        });
    }

    setRecordUrl(item) {
        let recordUrl;
        if (item.records) {
            item.records = item.records.map((row) => {
                recordUrl = `/${row.Id}`;
                return { ...row, recordUrl };
            });
        }
    }

    setCSS() {
        const items = this.template.querySelectorAll(".highlight-item");
        if (this.flexipageRegionWidth !== "SMALL") {
            items.forEach((item) => {
                item.classList.add("slds-size_2-of-12");
            });
        } else {
            items.forEach((item) => {
                item.classList.add("slds-size_6-of-12", "slds-m-vertical_xx-small");
            });
        }
        this.showItemSpacer =
            items.length % 2 !== 0 && this.flexipageRegionWidth === "SMALL";
    }

    expandHighlightItem(event) {
        let item = this.items[event.target.dataset.index];
        if (!item.errors && item.records.length === 0) {
            this.closeTable();
        }

        this.showTable = !this.showTable;

        if (item.errors) {
            this.expandedItemRecords = undefined;
            this.displayError = true;
            this.expandedItemError = item.errors[0];
        } else if (item.records.length > 0) {
            this.expandedItemPages = this.setPageSizes(item.records);
            this.expandedItemRecords = this.expandedItemPages[0];
            this.maxPage = this.expandedItemPages.length;
            this.tableColumns = this.columnsByItem.get(
                this.items[event.target.dataset.index].itemId
            );
        } else {
            this.closeTable();
        }
    }

    setPageSizes(arr) {
        const result = arr.reduce((resultArray, item, index) => {
            const chunkIndex = Math.floor(index / this.maxDisplayRows);
            if (!resultArray[chunkIndex]) {
                resultArray[chunkIndex] = [];
            }
            resultArray[chunkIndex].push(item);

            return resultArray;
        }, []);
        return result;
    }

    addRecordLink(item) {
        let recordUrl;
        item.records.map((row) => {
            recordUrl = `/${row.Id}`;
            return { ...row, recordUrl };
        });
    }

    closeTable() {
        this.expandedItemRecords = undefined;
        this.expandedItemError = undefined;
        this.showTable = false;
    }

    previousPage() {
        if (this.currentPage !== 1) {
            this.currentPage--;
        }
        this.expandedItemRecords = this.expandedItemPages[this.currentPage - 1];
    }

    nextPage() {
        if (this.currentPage !== this.maxPage) {
            this.currentPage++;
        }
        this.expandedItemRecords = this.expandedItemPages[this.currentPage - 1];
    }

    constructTableColumn(item) {
        const colArr = [];
        if (!item.fields) {
            return;
        }
        item.fields.forEach((field, index) => {
            let col;

            if (index === 0) {
                const typeAttributes = {
                    label: { fieldName: field.name },
                    target: `__blank`
                };
                const type = "url";
                col = new Column(
                    field.label,
                    "recordUrl",
                    type,
                    typeAttributes
                );
            } else {
                col = new Column(field.label, field.name);
            }
            colArr.push(col);
        });
        this.columnsByItem.set(item.itemId, colArr);
    }
}
