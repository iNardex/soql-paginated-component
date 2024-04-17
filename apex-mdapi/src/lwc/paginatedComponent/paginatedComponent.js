import { LightningElement, api, track } from 'lwc';
import retrievePaginatedResult from '@salesforce/apex/PaginatedController.retrievePaginatedResult';
import getUser from '@salesforce/apex/PaginatedController.getUser';
import getAccount from '@salesforce/apex/PaginatedController.getAccount';
import deleteItem from '@salesforce/apex/PaginatedController.deleteItem';
import retrieveObjectLabel from '@salesforce/apex/PaginatedController.retrieveObjectLabel';
import { NavigationMixin } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const ISO_DATE_REGEXP = /^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(\.\d+)?(([+-]\d\d:\d\d)|Z)?$/;

const ACTIONS =  { label: 'Delete', name: 'delete' };
const DOWNLOAD = { label: 'Download', name: 'download' };

const URL_DOWNLOAD = '/sfc/servlet.shepherd/version/download/';

const RECORD_STR = "{recordId}";
const USER_ID = "{userId}";
const ACCOUNT_ID = "{accountId}";
const CONTACT_ID = "{contactId}";

export default class PaginatedComponent extends NavigationMixin(LightningElement) {

    @api recordId;
    @api title;
    @api objectName;
    @api fields;
    @api row;
    @api deleteEnabled;
    @api downloadEnabled;
    @api cardIcon;
    @api nameAsLink;
    @api whereCondition;
    @api orderBy;
    @api searchEnabled;

    @track sortBy;
    @track sortDirection;

    fieldsDefinition = [];

    currentUser;
    currentAccount;
    isLoading = true;
    isEmpty = false;
    tableData = [];

    columns = [];
    currentPage = 1;
    pagesToView = 5;
    countRow = 0;
    pagination = [];

    connectedCallback(){
         retrieveObjectLabel({objectName: this.objectName}).
         then(labelMap => {
             this.generateTableColumns(labelMap);
             this.init();
         });
    }

    async init(){
        this.currentUser = await getUser();
        this.currentAccount = await getAccount({accountId: this.currentUser.AccountId});
        this.retrieveData();
    }

    generateTableColumns(labelMap){
        this.fieldsDefinition = this.fields.split(',').map(f=>f.trim());
        this.columns = this.fieldsDefinition.map(f=>{
            const def = {
                label: this.optimizeName(f, labelMap),
                fieldName: f,
                type: labelMap[f.toLowerCase()]?.type ?? 'text',
                sortable: labelMap[f.toLowerCase()]?.isSortable ?? false,
                hideDefaultActions: true
            }

			const fieldUpper = f.toUpperCase();
            if(this.nameAsLink && (fieldUpper != 'STAGENAME' && (fieldUpper.endsWith('NAME') || fieldUpper === 'NAME__C'))){
               def.fieldName = fieldUpper === 'NAME' || fieldUpper === 'NAME__C' ? 'URL' : fieldUpper.replace('.NAME', '.URL');
                def.type = 'url';
                def.typeAttributes = {
                    label: {
                        fieldName: f
                    }
                }
            }

            return def;
        });
        let actions = {
            type: 'action',
            typeAttributes: { rowActions: [] }
        }

        if(this.deleteEnabled){
            actions.typeAttributes.rowActions.push(ACTIONS);
        }

        if(this.downloadEnabled){
            actions.typeAttributes.rowActions.push(DOWNLOAD);
        }

        if (actions.typeAttributes.rowActions.length > 0) {
            this.columns.push(actions);
        }
    }

    optimizeName(name, labelMap) {
        return labelMap[name.toLowerCase()]?.label ?? name.replace('__c', '').replace('__r.', ' ');
    }

    parseWhereCondition(){
        if(!this.whereCondition){
            return undefined;
        }
        let whereCond = this.whereCondition.replace(RECORD_STR, this.recordId);
        if(this.currentUser){
            whereCond = whereCond.replace(USER_ID, '\'' + this.currentUser.Id + '\'');
            whereCond = whereCond.replace(CONTACT_ID, '\'' + this.currentUser.ContactId + '\'');
        }
        if(this.currentAccount){
            whereCond = whereCond.replace(ACCOUNT_ID, '\'' + this.currentAccount.Id + '\'');
        }
        return whereCond;
    }

    retrieveData(){
        this.isLoading = true;
        const criteria = {
            resultNum: this.row,
            pageNum: this.currentPage,
            whereCondition: this.parseWhereCondition(),
            orderBy: this.orderBy,
            inputSearch: this.inputSearch
        };

        retrievePaginatedResult({objectName: this.objectName, fields: this.fieldsDefinition, criteriaJson: JSON.stringify(criteria) })
        .then(result =>{
           this.manageRetrieveData(result);
        }).catch(error => {
           console.log('error ' + JSON.stringify(error));
           this.isLoading = false;
        });
    }

    async manageRetrieveData(result){
        let data = [...result.data];
        data = this.flatExternalObj(data);
        for(let row of data){
            let idsProp = Object.getOwnPropertyNames(row).filter(prop => prop.toUpperCase().endsWith('ID'));
            for(let prop of idsProp){

                let objectName = this.objectName;

                if(prop.indexOf('__r' ) !== -1 ){
                     objectName = prop.toUpperCase().replace('.ID', '').replace('__R', '__C');
                }

                const result = await this[NavigationMixin.GenerateUrl]({
                type: "standard__recordPage",
                attributes: {
                    recordId: row[prop],
                    objectApiName: objectName,
                    actionName: "view"
                }
                 });

                const key = prop.toUpperCase() === 'ID' ? 'URL' : prop.toUpperCase().replace('.ID', '.URL');
                row[key] = result;
            }

            Object.getOwnPropertyNames(row)
                .filter(prop => ISO_DATE_REGEXP.test(row[prop]))
                .forEach(prop => {
                    row[prop] = new Date(Date.parse(row[prop])).toLocaleString();
                });
        }

        this.tableData = [...data];
        this.isEmpty = result.resultNum === 0;
        this.countRow = result.resultNum;

        let numberOfPages = Math.floor(this.countRow / this.row) + (this.countRow % this.row === 0 ? 0 : 1);

        this.pagination = this.getPagingRange(Number(this.currentPage), numberOfPages)
            .map(el => {
                return {
                    pageNum: el,
                    disabled: this.currentPage == el
                }
            });

        this.isLoading = false;
    }

    /**
     * Return an integer range within [min, min + total) of given length centered
     * around the current page number.
     */
    getPagingRange(current, total) {
        let min = 1;
        let length = 5;
        if (length > total) length = total;

        let start = current - Math.floor(length / 2);
        start = Math.max(start, min);
        start = Math.min(start, min + total - length);

        return Array.from({length: length}, (el, i) => start + i);
    }

    changeInputSearch(event) {
        this.currentPage = 1;
        this.inputSearch = event.currentTarget.value;
        this.retrieveData();
    }

    flatExternalObj(data){
        return data.map(row => {
            Object.getOwnPropertyNames(row)
            .filter(prop => typeof row[prop] === 'object' )
            .map(prop => {
                let mapped = {};
                Object.getOwnPropertyNames(row[prop]).forEach(internalProp => mapped[prop + '.' + internalProp] = row[prop][internalProp]);
                return mapped;
            })
            .forEach(mapped=>{
               row = {
                   ...mapped,
                   ...row
               };
            });
            return row;
        });
    }

    handlePrev(event) {
        this.currentPage--;
        this.retrieveData();
    }

    handleNext(event) {
        this.currentPage++;
        this.retrieveData();
    }

    handleByPage(event) {
        this.currentPage = event.currentTarget.dataset.id;
        this.retrieveData();
    }

    handleRowAction(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;
            case 'download':
                this.downloadDoc(row);
                break;
            default:
        }
    }

    downloadDoc(row){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: window.location.origin + '/' + URL_DOWNLOAD + row.Id
            },
        });
    }

    deleteRow(row){
        this.isLoading = true;
        deleteItem({id: row.Id})
        .then(result => {
            const title = this.titleText + ' "' + row.Name + '" was deleted' ;
            const evt = new ShowToastEvent({
                title: title,
                variant: 'success',
            });
            this.dispatchEvent(evt);
            eval("$A.get('e.force:refreshView').fire();");
            this.retrieveData();
        })
        .catch(error=>{
            const evt = new ShowToastEvent({
                title: error?.body?.pageErrors[0]?.message ?? 'Error',
                variant: 'error',
            });
            this.dispatchEvent(evt);
			this.isLoading = false;
        });
    }

    handleSortData(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        console.log('fieldToSort ' + this.sortBy);
        this.orderBy = this.sortBy.replace('URL', 'NAME') + ' ' + this.sortDirection;
        this.retrieveData();
    }

    get disablePrevButton() {
       return this.currentPage === 1;
    }

    get disableNextButton(){
       if(!this.countRow || this.countRow === 0)
            return true;
       return this.currentPage * Number(this.row) >= this.countRow;
    }

    get titleText(){
        return this.title ?? this.optimizeName(this.objectName);
    }

}
